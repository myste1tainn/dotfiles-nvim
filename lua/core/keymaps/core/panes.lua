local keymap = vim.keymap.set

return function(bufnr)
	-- º is <M-0>
	keymap({ "n", "v", "i" }, "<M-0>", "<Esc><Cmd>messages<CR>", { desc = "Next Quickfix Item", silent = true })
	keymap(
		{ "n", "v", "i" },
		"<M-1>",
		"<Esc><Cmd>Neotree toggle<CR>",
		{ desc = "Toggle file explorer (neotree)", silent = true }
	)
	keymap({ "t" }, "<M-0>", "<C-\\><C-n><Cmd>messages<CR>", { desc = "Next Quickfix Item", silent = true })
	keymap(
		{ "t" },
		"<M-1>",
		"<C-\\><C-n><Cmd>Neotree toggle<CR>",
		{ desc = "Toggle file explorer (neotree)", silent = true }
	)
end
