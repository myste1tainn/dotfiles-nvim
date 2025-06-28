-- TODO: Make the state system supports multiple states per template, so in creates an illusion of Run configurations like Goland and such
local M = {}
local state_file = ".nvim/overseer/state.json"

local function get_state_path()
	return vim.fn.getcwd() .. "/" .. state_file
end

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return {}
	end
	local content = f:read("*a")
	f:close()
	local ok, decoded = pcall(vim.fn.json_decode, content)
	return (ok and decoded) or {}
end

local function write_file(path, data)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p") -- ensure `.nvim/` exists
	local f = io.open(path, "w")
	if not f then
		vim.notify("Failed to write overseer/state.json to " .. path, vim.log.levels.ERROR)
		return
	end
	f:write(vim.fn.json_encode(data))
	f:close()
end

-- Load state once per session
local state = read_file(get_state_path())

function M.set_last_params(name, params)
	state[name] = vim.deepcopy(params)
	write_file(get_state_path(), state)
end

function M.get_last_params(name)
	return state[name] or {}
end

return M
