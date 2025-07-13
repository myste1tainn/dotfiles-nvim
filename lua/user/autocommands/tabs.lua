local M = {}
M.last_visited_tab = nil

vim.api.nvim_create_autocmd("TabLeave", {
	callback = function()
		M.last_visited_tab = vim.fn.tabpagenr()
	end,
})

return M
