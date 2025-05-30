local keymap = vim.keymap.set

return function(bufnr)
	-- Toggling nvim-spectre
	keymap("n", "<leader>sp", ":lua require('spectre').toggle()<CR>", { desc = "Toggle Spectre" })
end
