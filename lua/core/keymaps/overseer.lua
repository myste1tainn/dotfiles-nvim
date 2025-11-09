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
	keymap_util.map_for_all_and_terminal({ keys = "<leader>rr", modes = { "n", "v" } }, function()
		vim.cmd("OverseerRun")
		-- TODO: It not possible to do this because the run prompt will not be there yet, and the windon is focused already
		--       Find a way to show this after the run prompt has been confirmed
		-- toggle_fn()
	end, { desc = "Run Overseer Task", silent = true })
	keymap_util.map_for_all_and_terminal({ keys = "<leader>rl", modes = { "n", "v" } }, function()
		vim.cmd("OverseerQuickAction restart")
		toggle_fn()
	end, { desc = "Restart Overseer Task", silent = true })
	-- keymap_util.map_for_all_and_terminal("<M-8>", toggle_fn, { desc = "Toggle Overseer", silent = true })
	keymap_util.map_for_all_and_terminal("<M-8>", toggle_fn, { desc = "Toggle Overseer", silent = true })

	local function smart_stop_overseer_tasks()
		-- If dap is running then stop dap sessions first
		local dap = require("dap")
		if dap.session() then
			dap.terminate()
		end

		-- Then if overseer tasks are running, stop them
		local overseer = require("overseer")
		local tasks = overseer.list_tasks()
		local has_running_tasks = false
		for _, task in ipairs(tasks) do
			if task:is_running() then
				has_running_tasks = true
				break
			end
		end
		if has_running_tasks then
			vim.cmd("OverseerQuickAction stop")
		end
	end
	keymap_util.map_for_all_and_terminal(
		"<M-s>",
		smart_stop_overseer_tasks,
		{ desc = "Stop last run overseer tasks", silent = true }
	)
end
