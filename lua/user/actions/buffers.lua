-- Map <leader>b to an on-the-fly menu of buffer actions ---------------------
local buf_actions = {
	["Switch to previous buffer"] = function()
		vim.cmd("b#")
	end,
	["Close OTHER buffers"] = function()
		vim.cmd("BufOnly")
	end,
	["Purge [No Name] buffers"] = function()
		vim.cmd("BufPurgeNoName")
	end,
}

return buf_actions
