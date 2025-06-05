local keymap = vim.keymap.set

return function(bufnr)
	local toggle_command = "<Cmd>OverseerToggle<CR>"
	-- Overseer uses
	keymap(
		{ "n", "v", "i" },
		"<leader>r",
		"<Esc><Cmd>OverseerRun<CR>" .. toggle_command,
		{ desc = "Run Overseer Task", silent = true }
	)
	keymap(
		{ "n", "v", "i" },
		"<leader>rr",
		"<Esc><Cmd>OverseerQuickAction restart<CR>" .. toggle_command,
		{ desc = "Run Overseer Task", silent = true }
	)
	-- ª = <M-9>
	keymap({ "n", "v", "i" }, "<M-9>", "<Esc>" .. toggle_command, { desc = "Toggle Overseer", silent = true })
	keymap(
		{ "n", "v", "i" },
		"<M-.>",
		"<Esc><Cmd>OverseerQuickAction stop<CR>",
		{ desc = "Stop last run overseer tasks", silent = true }
	)
	keymap({ "t" }, "<M-9>", "<C-\\><C-n>" .. toggle_command, { desc = "Toggle Overseer", silent = true })
	keymap(
		{ "t" },
		"<leader>rr",
		"<C-\\><C-n><Cmd>OverseerQuickAction restart<CR>" .. toggle_command,
		{ desc = "Run Overseer Task", silent = true }
	)
	keymap(
		{ "t" },
		"<M-.>",
		"<C-\\><C-n><Cmd>OverseerQuickAction stop<CR>",
		{ desc = "Stop last run overseer tasks", silent = true }
	)
end
