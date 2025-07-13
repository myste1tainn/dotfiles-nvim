local keymap = vim.keymap.set
local panes_util = require("utils.panes")
return {
	"lewis6991/gitsigns.nvim",
	event = "VeryLazy",
	opts = {
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns
			keymap("n", "<leader>gb", function()
				panes_util.toggle_pane({
					pane_open_predicate = {
						filetype = "gitsigns-blame",
					},
					on_pane_is_being_focused = function(win)
						vim.api.nvim_win_close(win.winid, true)
					end,
					on_pane_existed = function(win)
						vim.api.nvim_win_close(win.winid, true)
					end,
					on_pane_not_existed = function()
						vim.cmd("Gitsigns blame")
					end,
				})
			end, { desc = "Toggle Current Line Blame" })
			keymap("n", "<leader>gp", gs.preview_hunk, { desc = "Preview Hunk" })
			keymap("n", "<leader>gR", gs.reset_hunk, { desc = "Reset Hunk" })
			keymap("n", "<leader>gS", gs.stage_hunk, { desc = "Stage Hunk" })
			keymap("n", "<leader>gU", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
		end,
	},
}
