local keymap_util = require("utils.keymap")

-- TODO: Whenever quickfix is opened and then I tried to open overseer, it will be very short, find a way to fix this

return function(bufnr)
	-- Refactored using keymap_util.map_for_all_and_terminal
	keymap_util.map_for_all_and_terminal(
		{ keys = "<leader>rr", modes = { "n", "v" } },
		"<CMD>FlutterRun<CR>",
		{ desc = "Run FlutterRun", silent = true }
	)

	keymap_util.map_for_all_and_terminal(
		{ keys = "<leader>rl", modes = { "n", "v" } },
		"<CMD>FlutterRestart<CR>",
		{ desc = "Run FlutterRun", silent = true }
	)
	-- keymap_util.map_for_all_and_terminal("<M-8>", toggle_fn, { desc = "Toggle Overseer", silent = true })
	keymap_util.map_for_all_and_terminal(
		"<M-8>",
		"<CMD>FlutterLogToggle<CR>",
		{ desc = "Toggle Flutter Logs", silent = true }
	)
	keymap_util.map_for_all_and_terminal(
		"<M-s>",
		"<CMD>FluterQuit<CR>",
		{ desc = "Stop last run overseer tasks", silent = true }
	)
end
