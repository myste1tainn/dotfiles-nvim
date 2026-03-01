local panes_util = require("utils.panes")
local keymap = vim.keymap.set
-- local toggle_aerial = function()
-- 	-- Exit insert or terminal mode first
-- 	if vim.fn.mode() == "i" then
-- 		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
-- 	end
-- 	if vim.fn.mode() == "t" then
-- 		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
-- 	end
--
-- 	-- get current win objects in the current tab
-- 	local current_win = vim.api.nvim_get_current_win()
-- 	local current_buf = vim.api.nvim_win_get_buf(current_win)
-- 	-- if the current win is an aerial window, close it
-- 	if vim.api.nvim_buf_get_option(current_buf, "filetype") == "aerial" then
-- 		vim.cmd("AerialClose")
-- 		return
-- 	end
--
-- 	-- if the current win is not an aerial window, check if there is an aerial window in the current tab
-- 	local aerial_win = nil
-- 	for _, win in ipairs(vim.fn.getwininfo()) do
-- 		if win.tabnr == vim.fn.tabpagenr() then
-- 			-- if the window does not belong to the current tab, skip it
-- 			goto continue
-- 		end
-- 		if win.filetype == "aerial" then
-- 			aerial_win = win.winid
-- 		end
-- 		::continue::
-- 	end
--
-- 	if aerial_win then
-- 		-- if there is an aerial window, focus it
-- 		vim.api.nvim_set_current_win(aerial_win)
-- 	else
-- 		vim.cmd("AerialOpen")
-- 	end
-- end

return {
	"stevearc/aerial.nvim",
	opts = {},
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function(_, opts)
		local trouble = require("trouble")
		require("aerial").setup({
			-- optionally use on_attach to set keymaps when aerial has attached to a buffer
			on_attach = function(bufnr)
				-- Jump forwards/backwards with '{' and '}'
				keymap("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
				keymap("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
			end,
			-- Highlight the symbol in the source buffer when cursor is in the aerial win
			highlight_on_hover = true,

			-- When jumping to a symbol, highlight the line for this many ms.
			-- Set to false to disable
			highlight_on_jump = 300,

			-- Jump to symbol in source window when the cursor moves
			autojump = true,
		})
		-- You probably also want to set a keymap to toggle aerial
		keymap({ "n", "v", "i" }, "<M-2>", function()
			-- keymap({ "n", "v", "i" }, "<C-c>", function()
			panes_util.toggle_pane({
				pane_open_predicate = {
					customtype = function(win)
						local w = vim.w[win.winid].trouble
						if w == nil then
							return false
						end
						return w.mode == "symbols"
					end,
				},
				on_pane_is_being_focused = function(win)
					vim.cmd("Trouble symbols close")
				end,
				on_pane_existed = function(win)
					vim.cmd("Trouble symbols focus")
				end,
				on_pane_not_existed = function()
					local neo_tree_win = panes_util.find_win("neo-tree")
					if neo_tree_win then
						vim.api.nvim_win_close(neo_tree_win.winid, false)
					end
					trouble.open({ mode = "symbols", focus = true, win = { position = "left" } })
				end,
			})
		end, { desc = "Toggle Quickfix" })
		-- NOTE: Old one was Aerial, but now trying out Trouble.nvim
		-- keymap({ "n", "v", "i", "t" }, "<M-2>", function()
		-- 	panes_util.toggle_pane({
		-- 		pane_open_predicate = {
		-- 			filetype = { "aerial" },
		-- 		},
		-- 		on_pane_is_being_focused = function(win)
		-- 			vim.cmd("AerialToggle")
		-- 		end,
		-- 		on_pane_existed = function(win)
		-- 			vim.api.nvim_set_current_win(win.winid)
		-- 		end,
		-- 		on_pane_not_existed = function()
		-- 			vim.cmd("AerialOpen")
		-- 		end,
		-- 	})
		-- end, { desc = "Toggle Aerial" })

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "aerial",
			callback = function()
				vim.opt_local.wrap = true
				vim.opt_local.linebreak = true -- Optional: Prevents wrapping in the middle of words
			end,
		})
	end,
}
