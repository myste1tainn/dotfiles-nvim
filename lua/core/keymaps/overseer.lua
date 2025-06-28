local keymap_util = require("utils.keymap")
local panes_util = require("utils.panes")

-- TODO: Whenever quickfix is opened and then I tried to open overseer, it will be very short, find a way to fix this

return function(bufnr)
	local toggle_fn = function()
		panes_util.toggle_pane({
			pane_open_predicate = {
				filetype = "OverseerList",
			},
			on_pane_is_being_focused = function(win)
				vim.cmd("OverseerClose")
			end,
			on_pane_existed = function(win)
				vim.api.nvim_set_current_win(win.winid)
			end,
			on_pane_not_existed = function()
				vim.cmd("OverseerOpen")
			end,
		})
	end
	local toggle_command = "<Cmd>OverseerToggle<CR>"
	-- Refactored using keymap_util.map_for_all_and_terminal
	keymap_util.map_for_all_and_terminal({ keys = "<leader>r", modes = { "n", "v" } }, function()
		vim.cmd("OverseerRun")
		-- TODO: It not possible to do this because the run prompt will not be there yet, and the windon is focused already
		--       Find a way to show this after the run prompt has been confirmed
		-- toggle_fn()
	end, { desc = "Run Overseer Task", silent = true })
	keymap_util.map_for_all_and_terminal({ keys = "<leader>rr", modes = { "n", "v" } }, function()
		vim.cmd("OverseerQUickAction restart")
		toggle_fn()
	end, { desc = "Restart Overseer Task", silent = true })
	-- keymap_util.map_for_all_and_terminal("<M-9>", toggle_fn, { desc = "Toggle Overseer", silent = true })
	keymap_util.map_for_all_and_terminal("<M-9>", toggle_fn, { desc = "Toggle Overseer", silent = true })
	keymap_util.map_for_all_and_terminal(
		"<M-.>",
		"<Cmd>OverseerQuickAction stop<CR>",
		{ desc = "Stop last run overseer tasks", silent = true }
	)
end
