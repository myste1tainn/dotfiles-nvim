local M = {}
local history_file = ".nvim/overseer/history.json"

local function get_history_path()
	return vim.fn.getcwd() .. "/" .. history_file
end

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return {}
	end
	local content = f:read("*a")
	f:close()
	local ok, decoded = pcall(vim.fn.json_decode, content)
	if not ok or type(decoded) ~= "table" then
		return {}
	end
	return decoded
end

local function write_file(path, data)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
	local f = io.open(path, "w")
	if not f then
		vim.notify("Failed to write overseer history to " .. path, vim.log.levels.ERROR)
		return
	end
	f:write(vim.fn.json_encode(data))
	f:close()
end

local function params_equal(a, b)
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end
	for k, v in pairs(a) do
		if not params_equal(v, b[k]) then
			return false
		end
	end
	for k in pairs(b) do
		if a[k] == nil then
			return false
		end
	end
	return true
end

-- Loaded once per session from cwd at require time (matches state.lua behaviour)
local history = read_file(get_history_path())

function M.add(name, params)
	params = params or {}
	for i, item in ipairs(history) do
		if item.name == name and params_equal(item.params or {}, params) then
			table.remove(history, i)
			break
		end
	end
	table.insert(history, 1, { name = name, params = vim.deepcopy(params) })
	write_file(get_history_path(), history)
end

function M.get()
	return history
end

return M
