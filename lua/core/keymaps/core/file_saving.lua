local keymap = vim.keymap.set

return function(bufnr)
	-- Quit buffer, Save & Quit, Quit All, Save all & Quit
	keymap({ "n", "v", "i" }, "<C-q>", "<Esc><Cmd>q<CR>", { desc = "Quit Buffer", silent = true })
	keymap({ "n", "v", "i" }, "<C-a><C-q>", "<Esc><Cmd>qa<CR>", { desc = "Quit All", silent = true })
	keymap({ "n", "v", "i" }, "<C-a><C-s>", "<Esc><Cmd>wa<CR>", { desc = "Save All & Quit", silent = true })
	keymap({ "n", "v", "i" }, "<C-s>", "<Esc><Cmd>wa<CR>", { desc = "Save", silent = true })
	keymap({ "t" }, "<C-q>", "<C-\\><C-n><Cmd>q<CR>", { desc = "Quit Buffer", silent = true })
	keymap({ "t" }, "<C-a><C-q>", "<C-\\><C-n><Cmd>qa<CR>", { desc = "Quit All", silent = true })
	keymap({ "t" }, "<C-a><C-s>", "<C-\\><C-n><Cmd>wa<CR>", { desc = "Save All & Quit", silent = true })
	keymap({ "t" }, "<C-s>", "<C-\\><C-n><Cmd>wa<CR>", { desc = "Save", silent = true })
end
