local keymap = vim.keymap.set

return function(bufnr)
	-- Launching FzfLua
	keymap("n", "<leader>f", ":FzfLua<CR>", { desc = "Launch FzfLua" })
	keymap("n", "<leader>ff", ":FzfLua files<CR>", { desc = "Launch FzfLua files" })
	keymap("n", "<leader>fg", ":FzfLua grep<CR>", { desc = "Launch FzfLua grep" })
end
