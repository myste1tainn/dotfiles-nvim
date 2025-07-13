local keymap_util = require("utils.keymap")
local panes_util = require("utils.panes")
local wins_util = require("utils.wins")

return function(bufnr)
	-- keymap_util.map_for_all_and_terminal("<M-9>", "<Cmd>NoiceAll<CR>", { desc = "Open NoiceAll", silent = true })
	keymap_util.map_for_all_and_terminal("<M-9>", function()
		panes_util.toggle_pane({
			pane_open_predicate = {
				filetype = "noice",
			},
			on_pane_is_being_focused = function(win)
				vim.cmd("NoiceDismiss")
				vim.cmd("q")
			end,
			on_pane_existed = function(win)
				vim.api.nvim_set_current_win(win.winid)
			end,
			on_pane_not_existed = function()
				vim.cmd("NoiceAll")
			end,
		})
	end, { desc = "Open NoiceAll", silent = true })
	-- keymap_util.map_for_all_and_terminal(
	-- 	"<M-1>",
	-- 	"<Cmd>Neotree toggle<CR>",
	-- 	{ desc = "Toggle file explorer (neotree)", silent = true }
	-- )
	keymap_util.map_for_all_and_terminal("<M-1>", function()
		panes_util.toggle_pane({
			pane_open_predicate = {
				filetype = "neo-tree",
			},
			on_pane_is_being_focused = function(win)
				vim.cmd("Neotree close")
			end,
			on_pane_existed = function(win)
				vim.api.nvim_set_current_win(win.winid)
			end,
			on_pane_not_existed = function()
				require("trouble").close("symbols")
				vim.cmd("Neotree focus")
			end,
		})
	end, { desc = "Toggle file explorer (neotree)", silent = true })

	keymap_util.map_for_all_and_terminal(
		"<M-r>",
		panes_util.open_current_buffer_in_float,
		{ desc = "Open Buffer in Floating Window", silent = true }
	)

	keymap_util.map_for_all_and_terminal("<M-0>", function()
		local curr_win = vim.api.nvim_get_current_win()
		local main_win = panes_util.find_main_editor_window()
		if main_win ~= nil and curr_win ~= main_win then
			vim.api.nvim_set_current_win(main_win)
		end
	end, { desc = "Focus main editor window", silent = true })
end
