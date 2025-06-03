local keymap = vim.keymap.set

return function(bufnr)
	-- Launching FzfLua
	keymap("n", "<leader>f", "<Cmd>FzfLua<CR>", { desc = "Launch FzfLua", silent = true })
	keymap("n", "<leader>ff", "<Cmd>FzfLua files<CR>", { desc = "Launch FzfLua files", silent = true })
	keymap("n", "<leader>fl", "<Cmd>FzfLua live_grep<CR>", { desc = "Launch FzfLua live_grep", silent = true })
	keymap("n", "<leader>fb", "<Cmd>FzfLua buffers<CR>", { desc = "Launch FzfLua buffers", silent = true })
	keymap("n", "<leader>fg", "<Cmd>FzfLua git_files<CR>", { desc = "Launch FzfLua git_files", silent = true })
	keymap("n", "<leader>fd", "<Cmd>FzfLua git_diff<CR>", { desc = "Launch FzfLua git_diff", silent = true })
end
