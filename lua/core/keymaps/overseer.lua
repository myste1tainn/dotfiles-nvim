local keymap = vim.keymap.set

return function(bufnr)
	-- Overseer uses
	keymap({ "n", "v", "i" }, "<leader>r", "<Esc><Cmd>OverseerRun<CR>", { desc = "Run Overseer Task", silent = true })
	-- ª = <M-9>
	keymap({ "n", "v", "i" }, "<M-9>", "<Esc><Cmd>OverseerToggle<CR>", { desc = "Toggle Overseer", silent = true })
	keymap(
		{ "n", "v", "i" },
		"<M-.>",
		"<Esc><Cmd>OverseerQuickAction stop<CR>",
		{ desc = "Stop last run overseer tasks", silent = true }
	)
	keymap({ "t" }, "<M-9>", "<C-\\><C-n><Cmd>OverseerToggle<CR>", { desc = "Toggle Overseer", silent = true })
	keymap(
		{ "t" },
		"<M-.>",
		"<C-\\><C-n><Cmd>OverseerQuickAction stop<CR>",
		{ desc = "Stop last run overseer tasks", silent = true }
	)
end
