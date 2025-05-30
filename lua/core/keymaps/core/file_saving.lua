local keymap = vim.keymap.set

return function(bufnr)
	-- Quit buffer, Save & Quit, Quit All, Save all & Quit
	keymap({ "n", "v", "i" }, "<C-q>", "<Esc>:q<CR>", { desc = "Quit Buffer" })
	keymap({ "n", "v", "i" }, "<C-a><C-q>", "<Esc>:qa<CR>", { desc = "Quit All" })
	keymap({ "n", "v", "i" }, "<C-a><C-s>", "<Esc>:wa<CR>", { desc = "Save All & Quit" })
	keymap({ "n", "v", "i" }, "<C-s>", "<Esc>:wa<CR>", { desc = "Save" })
end
