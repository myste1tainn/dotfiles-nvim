local keymap = vim.keymap.set

return function(bufnr)
	keymap("n", "<leader>gg", "<Cmd>Neogit<CR>", { desc = "Toggle Neogit", silent = true })
	keymap("n", "<leader>gd", function()
		local count = vim.v.count
		if count == 0 then
			vim.cmd("DiffviewOpen")
		else
			vim.cmd("DiffviewOpen HEAD~" .. count)
		end
	end, { desc = "Show Diff", silent = true })
	keymap("n", "<leader>gdc", ":DiffviewOpen ", { desc = "Show Diff of choice", silent = true })
end
