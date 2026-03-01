local M = {}

M.condition = {
	filetype = { "go", "gomod", "gosum" },
	-- callback = function()
	-- 	-- Check if the current working directory is a Go project
	-- 	local is_cwd_go = vim.fn.filereadable("go.mod") == 1 or vim.fn.filereadable("go.sum") == 1
	-- 	-- Check if the current buffer is a Go file
	-- 	local is_buffer_go = vim.bo.filetype == "go"
	-- 	return is_cwd_go or is_buffer_go
	-- end,
}

return M
