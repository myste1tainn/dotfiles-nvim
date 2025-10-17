local uv = vim.loop
local M = {}
local env_watchers = {}
local watched_files = {}
local tracked_env_keys = {}

local function strip_outer_quotes(val)
	if not val then
		return val
	end
	val = val:match("^%s*(.-)%s*$") -- trim spaces
	local first = val:sub(1, 1)
	local last = val:sub(-1)
	if (first == last) and (first == '"' or first == "'") and #val >= 2 then
		return val:sub(2, -2)
	end
	return val
end

local function strip_trailing_comment(val)
	if not val then
		return val
	end
	local in_single_quote = false
	local in_double_quote = false
	local escape_next = false
	for i = 1, #val do
		local char = val:sub(i, i)
		if escape_next then
			escape_next = false
		elseif char == "\\" then
			escape_next = true
		elseif char == "'" and not in_double_quote then
			in_single_quote = not in_single_quote
		elseif char == '"' and not in_single_quote then
			in_double_quote = not in_double_quote
		elseif char == "#" and not in_single_quote and not in_double_quote then
			return val:sub(1, i - 1):match("^%s*(.-)%s*$") -- trim spaces before comment
		end
	end
	return val:match("^%s*(.-)%s*$") -- trim spaces if no comment found
end

local function parse_env_file(filepath)
	local vars = {}
	local file = io.open(filepath, "r")
	if not file then
		return vars
	end
	for line in file:lines() do
		local str = line:match("^%s*(.-)%s*$") -- trim
		if not (str == "" or str:match("^#")) then
			-- Try: export FOO=BAR or export FOO="BAR" or export FOO='BAR'
			local key, val = str:match("^export%s+([A-Za-z_][A-Za-z0-9_]*)%s*=%s*(.*)$")
			if not key then
				-- Try: FOO=BAR or FOO="BAR" or FOO='BAR'
				key, val = str:match("^([A-Za-z_][A-Za-z0-9_]*)%s*=%s*(.*)$")
			end
			if key and val then
				-- NOTES: Have to be in this order, otherwise the trailing comments can mess with the quotes detection
				val = strip_trailing_comment(val)
				val = strip_outer_quotes(val)
				vars[key] = val
			else
				vim.schedule(function()
					vim.notify(
						string.format("[direnv_watch] Cannot parse line: %q in %s", line, filepath),
						vim.log.levels.ERROR
					)
				end)
			end
		end
	end
	file:close()
	return vars
end

-- Tracks current values (union across all files)
local function update_env_from_files(envfiles, is_first_run)
	-- Gather all keys and new values
	local new_vars = {}
	for _, file in ipairs(envfiles) do
		-- if the file basename is .envrc then skip it
		if file:match("/%.envrc$") then
			goto continue
		end
		local vars = parse_env_file(file)
		for k, v in pairs(vars) do
			new_vars[k] = v
		end
		::continue::
	end

	-- Notify on add/change, and update
	local count = 0
	for k, v in pairs(new_vars) do
		local old = vim.env[k]
		if old ~= v then
			vim.env[k] = v
			if not is_first_run then
				vim.schedule(function()
					vim.notify(
						string.format("[direnv_watch] %s: %q → %q", k, tostring(old), tostring(v)),
						vim.log.levels.INFO
					)
				end)
			else
				count = count + 1
			end
		end
		tracked_env_keys[k] = true -- Always mark as tracked if present in env files
	end
	if is_first_run then
		vim.schedule(function()
			if count == 0 then
				-- Do nothing, since there were no variables loaded
			else
				vim.notify(
					string.format("[direnv_watch] Loaded %d environment variables from direnv files", count),
					vim.log.levels.INFO
				)
			end
		end)
	end

	-- Detect and unset removed keys
	for k, _ in pairs(tracked_env_keys) do
		if new_vars[k] == nil and vim.env[k] ~= nil then
			local old_val = vim.env[k]
			vim.env[k] = nil
			vim.schedule(function()
				vim.notify(
					string.format("[direnv_watch] [REMOVED] %s: %q → nil", k, tostring(old_val)),
					vim.log.levels.WARN
				)
			end)
			tracked_env_keys[k] = nil -- Remove from tracking
		end
	end
end

local function run_direnv_allow(cwd)
	local handle = io.popen("direnv allow " .. vim.fn.shellescape(cwd) .. " 2>&1")
	if handle then
		local output = handle:read("*a")
		handle:close()
		if output and #output > 0 then
			vim.schedule(function()
				vim.notify("[direnv_watch] direnv allow output:\n" .. output, vim.log.levels.INFO)
			end)
		end
	end
end

local function clear_watchers()
	for _, watcher in pairs(env_watchers) do
		watcher:stop()
	end
	env_watchers = {}
	watched_files = {}
end

local function get_files(cwd)
	local files = {}
	local envrc_path = cwd .. "/.envrc"
	if vim.fn.filereadable(envrc_path) == 1 then
		table.insert(files, envrc_path)
		run_direnv_allow(cwd)

		for line in io.lines(envrc_path) do
			-- Remove comments and trim whitespace
			local code = line:match("^[^#]*"):gsub("^%s+", ""):gsub("%s+$", "")
			-- Match `dotenv` and `dotenv_if_exists`
			local dotenv_file = code:match("^dotenv%s+([%w%._/-]+)") or code:match("^dotenv_if_exists%s+([%w%._/-]+)")
			if dotenv_file then
				local fullpath = cwd .. "/" .. dotenv_file
				if vim.fn.filereadable(fullpath) == 1 and not watched_files[fullpath] then
					table.insert(files, fullpath)
				end
			end
		end
	end
	return files
end

local function watch_files(cwd)
	clear_watchers()
	local files = get_files(cwd)

	-- Watch each file for changes
	for _, file in ipairs(files) do
		local w = uv.new_fs_poll()
		env_watchers[file] = w
		watched_files[file] = true
		w:start(
			file,
			500,
			vim.schedule_wrap(function(err)
				if err then
					vim.notify("[direnv_watch] FS error: " .. err, vim.log.levels.ERROR)
					return
				end
				if file:sub(-5) == ".envrc" then
					run_direnv_allow(cwd)
				else
					update_env_from_files(files, false)
				end
			end)
		)
	end
	return files
end

local function on_cwd_change()
	local cwd = vim.loop.cwd()
	local envfiles = watch_files(cwd)
	update_env_from_files(envfiles, true)
end

function M.setup()
	-- On nvim startup and on DirChanged, run the logic
	vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
		callback = on_cwd_change,
		group = vim.api.nvim_create_augroup("DirenvWatch", { clear = true }),
	})
end

return M
