local keymap = vim.keymap.set

return function(bufnr)
	-- Split movement within the same tab
	keymap("n", "<M-h>", "<Esc><C-w>h", { desc = "Move to left split" })
	keymap("n", "<M-l>", "<Esc><C-w>l", { desc = "Move to right split" })
	keymap("n", "<M-j>", "<Esc><C-w>j", { desc = "Move to below split" })
	keymap("n", "<M-k>", "<Esc><C-w>k", { desc = "Move to above split" })

	-- Tab movement
	-- † = <M-t>
	keymap({ "n", "v", "i" }, "<M-t>", "<Esc>:tabnew<CR>", { desc = "New tab" })
	-- “ = <M-[>
	keymap({ "n", "v", "i" }, "<M-[>", "<Esc>:tabnext<CR>", { desc = "Next tab" })
	-- ‘ = <M-]>
	keymap({ "n", "v", "i" }, "<M-]>", "<Esc>:tabprevious<CR>", { desc = "Previous tab" })
end
