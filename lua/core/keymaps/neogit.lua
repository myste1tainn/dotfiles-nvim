local keymap = vim.keymap.set

return function(bufnr)
	keymap("n", "<leader>gg", "<Cmd>Neogit<CR>", { desc = "Toggle Neogit", silent = true })
	keymap("n", "<leader>gdd", function()
		local count = vim.v.count
		if count == 0 then
			vim.cmd("DiffviewOpen")
		else
			vim.cmd("DiffviewOpen HEAD~" .. count)
		end
	end, { desc = "Show Diff", silent = true })
	keymap("n", "<leader>gdc", "<CMD>DiffviewClose<CR>", { desc = "Close the diff view", silent = true })
	keymap(
		"n",
		"<leader>gds",
		":DiffviewClose ",
		{ desc = "Show Diff of the specify commit/branch/tag", silent = true }
	)
end
