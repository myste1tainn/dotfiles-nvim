local keymap_util = require("utils.keymap")

return function(bufnr)
	local toggle_command = "<Cmd>OverseerToggle<CR>"
	-- Refactored using keymap_util.map_for_all_and_terminal
	keymap_util.map_for_all_and_terminal("<leader>r", "<Cmd>OverseerRun<CR>", { desc = "Run Overseer Task", silent = true })
	keymap_util.map_for_all_and_terminal("<leader>rr", "<Cmd>OverseerQuickAction restart<CR>" .. toggle_command, { desc = "Run Overseer Task", silent = true })
	keymap_util.map_for_all_and_terminal("<M-9>", toggle_command, { desc = "Toggle Overseer", silent = true })
	keymap_util.map_for_all_and_terminal("<M-.>", "<Cmd>OverseerQuickAction stop<CR>", { desc = "Stop last run overseer tasks", silent = true })
end
