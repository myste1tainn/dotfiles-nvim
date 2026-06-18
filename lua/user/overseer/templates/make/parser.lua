-- Minimal, dependency-free Makefile parser.
-- Extracts runnable targets and, per target, the Make variables ($(VAR)/${VAR})
-- and shell environment variables ($$VAR/$${VAR}) referenced in its recipe.
-- It also collects top-level variable assignments so callers can tell whether a
-- referenced variable has a default (optional) or not (mandatory).

local M = {}

-- A runnable target must be a plain identifier: letters/digits/underscore/hyphen,
-- not starting with a hyphen. This excludes special targets (.PHONY), pattern
-- rules (%.o), file/path targets (bin/app, foo.o) and computed names ($(X)).
function M.is_command_name(name)
	return name:match("^[%w_][%w_%-]*$") ~= nil
end

-- Record shell environment variable references ($$VAR / $${VAR}) into a set.
-- $$ is an escaped dollar in Make, so the following token is a shell env var.
-- Shared with the tree-sitter parser, whose grammar collapses $$ into an
-- `escape` node and does not expose the env var name.
function M.scan_env_refs(s, env_set)
	local i = 1
	local n = #s
	while i <= n do
		local dollar = s:find("$", i, true)
		if not dollar then
			break
		end
		if s:sub(dollar + 1, dollar + 1) == "$" then
			local rest = dollar + 2
			local name = s:match("^{([%w_]+)}", rest) or s:match("^([%w_]+)", rest)
			if name then
				env_set[name] = true
			end
			i = dollar + 2
		else
			i = dollar + 1
		end
	end
end

-- Walk a string and record variable references into the given sets.
--   $(NAME) / ${NAME}  -> Make variable (must close immediately, so function
--                         calls like $(shell ...) are skipped)
--   $$NAME / $${NAME}  -> shell environment variable ($$ is an escaped $)
local function scan_refs(s, make_set, env_set)
	local i = 1
	local n = #s
	while i <= n do
		local dollar = s:find("$", i, true)
		if not dollar then
			break
		end
		local nxt = s:sub(dollar + 1, dollar + 1)
		if nxt == "$" then
			-- escaped dollar; env vars handled by scan_env_refs below
			i = dollar + 2
		elseif nxt == "(" then
			local name = s:match("^%(([%w_]+)%)", dollar + 1)
			if name then
				make_set[name] = true
			end
			i = dollar + 2
		elseif nxt == "{" then
			local name = s:match("^%{([%w_]+)%}", dollar + 1)
			if name then
				make_set[name] = true
			end
			i = dollar + 2
		else
			i = dollar + 1
		end
	end
	M.scan_env_refs(s, env_set)
end

-- Join Make line continuations (a line ending in a single backslash continues
-- onto the next). Recipe-ness is determined by the first physical line's leading
-- tab, since only tab-prefixed lines are recipe lines.
local function logical_lines(content)
	local raw = vim.split(content, "\n", { plain = true })
	local out = {}
	local i = 1
	while i <= #raw do
		local line = raw[i]
		local is_recipe = line:sub(1, 1) == "\t"
		while line:sub(-1) == "\\" do
			line = line:sub(1, -2)
			i = i + 1
			local nxt = raw[i]
			if not nxt then
				break
			end
			line = line .. " " .. nxt
		end
		table.insert(out, { text = line, is_recipe = is_recipe })
		i = i + 1
	end
	return out
end

local DIRECTIVE_SKIP = {
	ifeq = true,
	ifneq = true,
	ifdef = true,
	ifndef = true,
	["else"] = true,
	endif = true,
	include = true,
	sinclude = true,
	["-include"] = true,
	vpath = true,
	export = true,
	unexport = true,
}

---@param content string raw Makefile contents
---@return { targets: table[], assignments: table<string, { value: string, dynamic: boolean }> }
function M.parse(content)
	local lines = logical_lines(content)

	local assignments = {} -- name -> { value, dynamic }
	local phony = {} -- name -> true
	local order = {} -- list of target entries, first-seen order
	local by_name = {} -- name -> entry
	local current = {} -- target entries that own the recipe lines that follow
	local in_define = false

	local function get_or_create(name)
		local t = by_name[name]
		if not t then
			t = { name = name, make = {}, env = {}, has_recipe = false, has_prereqs = false }
			by_name[name] = t
			table.insert(order, t)
		end
		return t
	end

	for _, item in ipairs(lines) do
		local line = item.text
		if in_define then
			if line:match("^%s*endef%s*$") then
				in_define = false
			end
		elseif item.is_recipe then
			for _, t in ipairs(current) do
				t.has_recipe = true
				scan_refs(line, t.make, t.env)
			end
		else
			local trimmed = line:gsub("^%s+", "")
			local first_word = trimmed:match("^([%w_%-]+)")
			if trimmed == "" or trimmed:sub(1, 1) == "#" then
				-- blank or comment: nothing to do
			elseif trimmed:match("^define%s") then
				local name = trimmed:match("^define%s+([%w_.%-]+)")
				if name then
					assignments[name] = { value = "", dynamic = true }
				end
				in_define = true
				current = {}
			else
				-- Try variable assignment first. The operator (=, :=, ?=, +=, !=, ::=)
				-- must terminate in '=' immediately after an optional run of :?!+,
				-- which a target line ("foo: bar") never satisfies.
				local assign_body = trimmed:gsub("^export%s+", ""):gsub("^override%s+", ""):gsub("^private%s+", "")
				local name, _, value = assign_body:match("^([%w_.%-]+)%s*([:?!+]*=)%s*(.*)$")
				if name then
					assignments[name] = { value = value, dynamic = value:find("%$") ~= nil }
					current = {}
				elseif first_word and DIRECTIVE_SKIP[first_word] then
					current = {}
				else
					-- Target rule: names before the first ':' that is not part of ':='.
					local targets_part, prereqs = trimmed:match("^([^:=]+):%s*(.*)$")
					if targets_part then
						local names = vim.split(vim.trim(targets_part), "%s+", { trimempty = true })
						if names[1] == ".PHONY" or names[1] == ".phony" then
							for p in prereqs:gmatch("[%w_%-]+") do
								phony[p] = true
							end
							current = {}
						else
							current = {}
							local has_prereqs = vim.trim(prereqs) ~= ""
							for _, tname in ipairs(names) do
								if M.is_command_name(tname) then
									local t = get_or_create(tname)
									if has_prereqs then
										t.has_prereqs = true
									end
									table.insert(current, t)
								end
							end
						end
					else
						current = {}
					end
				end
			end
		end
	end

	local function set_to_sorted_list(set)
		local list = {}
		for k in pairs(set) do
			table.insert(list, k)
		end
		table.sort(list)
		return list
	end

	local targets = {}
	for _, t in ipairs(order) do
		if t.has_recipe or phony[t.name] or t.has_prereqs then
			table.insert(targets, {
				name = t.name,
				make = set_to_sorted_list(t.make),
				env = set_to_sorted_list(t.env),
			})
		end
	end

	return { targets = targets, assignments = assignments }
end

return M
