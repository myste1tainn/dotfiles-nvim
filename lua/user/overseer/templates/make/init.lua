-- Custom Makefile task provider for overseer.
--
-- Replaces overseer's builtin "make" template (disabled via
-- disable_template_modules in lua/plugins/overseer.lua). For each runnable
-- target it produces a template named "{N}. Make {target}", deriving parameters
-- from the variables the target's recipe references:
--   * Make variable with a Makefile default      -> optional param
--   * Make variable referenced but never assigned -> mandatory param
--   * Shell environment variable ($$VAR)          -> optional param
--
-- The Makefile is read asynchronously (libuv) so listing never blocks the UI,
-- and no cache_key is provided so each :OverseerRun re-reads the current file.

local parser = require("user.overseer.templates.make.parser")
local ts = require("user.overseer.templates.make.treesitter")

-- Prefer the tree-sitter parser (robust to Make syntax); fall back to the
-- text parser when the `make` grammar is unavailable or errors.
local function parse_makefile(content)
	local ok, parsed = pcall(ts.parse, content)
	if ok and parsed then
		return parsed
	end
	return parser.parse(content)
end

-- Param form ordering bands (lower order = higher in the form). overseer sorts
-- params with `order` ascending, before unordered ones. We use the bands to
-- group params into sections: required knobs first, intended overridable knobs
-- next, and computed values (overridable but not meant to be set) last.
local ORDER_REQUIRED = 100 -- referenced but never assigned -> must supply
local ORDER_INTENDED = 1000 -- ?= / static = / := defaults and $$ENV vars
local ORDER_COMPUTED = 9000 -- = / := with computed ($(...)) values

local function get_makefile(dir)
	return vim.fs.find({ "Makefile", "makefile", "GNUmakefile" }, { upward = true, type = "file", path = dir })[1]
end

local function build_templates(cwd, content)
	local parsed = parse_makefile(content)
	local total = #parsed.targets
	local width = #tostring(math.max(total, 1))

	local templates = {}
	for index, tgt in ipairs(parsed.targets) do
		local params = {}
		local make_names = {}
		local env_names = {}
		local n_required, n_intended, n_computed = 0, 0, 0

		for _, var in ipairs(tgt.make) do
			local assigned = parsed.assignments[var]
			if not assigned then
				params[var] = {
					type = "string",
					optional = false,
					order = ORDER_REQUIRED + n_required,
					desc = "Make variable (required)",
				}
				n_required = n_required + 1
			elseif assigned.dynamic then
				params[var] = {
					type = "string",
					optional = true,
					default = "",
					order = ORDER_COMPUTED + n_computed,
					desc = "Computed Makefile default; leave blank unless overriding",
				}
				n_computed = n_computed + 1
			else
				params[var] = {
					type = "string",
					optional = true,
					default = assigned.value,
					order = ORDER_INTENDED + n_intended,
					desc = "Make variable (default: " .. assigned.value .. ")",
				}
				n_intended = n_intended + 1
			end
			table.insert(make_names, var)
		end

		for _, var in ipairs(tgt.env) do
			if not params[var] then
				params[var] = {
					type = "string",
					optional = true,
					default = vim.env[var] or "",
					order = ORDER_INTENDED + n_intended,
					desc = "Environment variable",
				}
				n_intended = n_intended + 1
				table.insert(env_names, var)
			end
		end

		local target = tgt.name
		templates[index] = {
			name = string.format("Make: %0" .. width .. "d. - %s", index, target),
			desc = "make " .. target,
			params = params,
			builder = function(p)
				local args = { target }
				for _, var in ipairs(make_names) do
					local val = p[var]
					if val ~= nil and val ~= "" then
						table.insert(args, string.format("%s=%s", var, val))
					end
				end
				local env
				for _, var in ipairs(env_names) do
					local val = p[var]
					if val ~= nil and val ~= "" then
						env = env or {}
						env[var] = val
					end
				end
				local task = {
					name = "make " .. target,
					cmd = { "make" },
					args = args,
					cwd = cwd,
					components = { "default", "on_output_quickfix" },
				}
				if env then
					task.env = env
				end
				return task
			end,
		}
	end

	return templates
end

return {
	{
		name = "make",
		generator = function(opts, cb)
			if vim.fn.executable("make") == 0 then
				return cb({})
			end
			local makefile = get_makefile(opts.dir)
			if not makefile then
				return cb({})
			end
			local cwd = vim.fs.dirname(makefile)

			-- Build + cb run on the main loop (vim.schedule); the libuv fs
			-- callbacks run in a fast-event context where vim.env/vim.fs are
			-- unavailable, so only raw IO happens there.
			local function finish(content)
				vim.schedule(function()
					if not content then
						return cb({})
					end
					local ok, templates = pcall(build_templates, cwd, content)
					cb(ok and templates or {})
				end)
			end

			vim.uv.fs_open(makefile, "r", 420, function(open_err, fd)
				if open_err or not fd then
					return finish(nil)
				end
				vim.uv.fs_fstat(fd, function(stat_err, stat)
					if stat_err or not stat then
						vim.uv.fs_close(fd)
						return finish(nil)
					end
					vim.uv.fs_read(fd, stat.size, 0, function(read_err, data)
						vim.uv.fs_close(fd)
						finish((not read_err) and data or nil)
					end)
				end)
			end)
		end,
	},
}
