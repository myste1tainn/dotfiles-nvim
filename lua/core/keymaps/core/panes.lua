local keymap = vim.keymap.set

return function(bufnr)
	-- º is <M-0>
	keymap({ "n", "v", "i" }, "<M-0>", "<Esc>:mes<CR>", { desc = "Next Quickfix Item" })
end
