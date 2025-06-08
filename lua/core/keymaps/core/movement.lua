local keymap = vim.keymap.set

return function(bufnr)
	-- Split movement within the same tab
	keymap({ "n", "v", "i" }, "<M-h>", "<Esc><C-w>h", { desc = "Move to left split" })
	keymap({ "n", "v", "i" }, "<M-l>", "<Esc><C-w>l", { desc = "Move to right split" })
	keymap({ "n", "v", "i" }, "<M-j>", "<Esc><C-w>j", { desc = "Move to below split" })
	keymap({ "n", "v", "i" }, "<M-k>", "<Esc><C-w>k", { desc = "Move to above split" })
	keymap({ "t" }, "<M-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left split" })
	keymap({ "t" }, "<M-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right split" })
	keymap({ "t" }, "<M-j>", "<C-\\><C-n><C-w>j", { desc = "Move to below split" })
	keymap({ "t" }, "<M-k>", "<C-\\><C-n><C-w>k", { desc = "Move to above split" })

	-- Tab movement
	-- † = <M-t>
	keymap({ "n", "v", "i" }, "<M-t>", "<Esc><Cmd>tabnew<CR>", { desc = "New tab", silent = true })
	-- “ = <M-[>
	keymap({ "n", "v", "i" }, "<M-[>", "<Esc><Cmd>tabprevious<CR>", { desc = "Next tab", silent = true })
	-- ‘ = <M-]>
	keymap({ "n", "v", "i" }, "<M-]>", "<Esc><Cmd>tabnext<CR>", { desc = "Previous tab", silent = true })
	keymap({ "t" }, "<M-t>", "<C-\\><C-n><Cmd>tabnew<CR>", { desc = "New tab", silent = true })
	keymap({ "t" }, "<M-[>", "<C-\\><C-n><Cmd>tabnext<CR>", { desc = "Next tab", silent = true })
	keymap({ "t" }, "<M-]>", "<C-\\><C-n><Cmd>tabprevious<CR>", { desc = "Previous tab", silent = true })
end
