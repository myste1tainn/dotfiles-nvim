local keymap = vim.keymap.set

return function(bufnr)
	-- º is <M-0>
	keymap({ "n", "v", "i" }, "<M-0>", "<Esc><Cmd>messages<CR>", { desc = "Next Quickfix Item" })
	keymap({ "n", "v", "i" }, "<M-1>", "<Esc><Cmd>Neotree toggle<CR>", { desc = "Toggle file explorer (neotree)" })
end
