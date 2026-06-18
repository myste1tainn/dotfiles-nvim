local keymap = vim.keymap.set
local panes_util = require("utils.panes")
local qf = require("object.quickfix")
local dg = require("object.diagnostics")

-- local function resize_quickfix(win)
-- 	if vim.api.nvim_win_is_valid(win) then
-- 		vim.api.nvim_set_current_win(win)
-- 		vim.cmd("wincmd J")
-- 		vim.cmd("resize 15")
-- 	end
-- end
--
-- -- Always open quickfix window at the bottom
-- vim.api.nvim_create_autocmd("BufWinEnter", {
-- 	callback = function(args)
-- 		if vim.api.nvim_buf_get_option(args.buf, "buftype") == "quickfix" then
-- 			vim.schedule(function()
-- 				resize_quickfix(vim.fn.win_getid())
-- 			end)
-- 		end
-- 	end,
-- })

return function(bufnr)
	local trouble = require("trouble")
	-- Toggling Quickfix
	keymap({ "n", "v", "i" }, "<M-4>", function()
		-- keymap({ "n", "v", "i" }, "<C-c>", function()
		panes_util.toggle_pane({
			pane_open_predicate = {
				customtype = function(win)
					local w = vim.w[win.winid].trouble
					if w == nil then
						return false
					end
					return w.mode == "quickfix"
				end,
			},
			on_pane_is_being_focused = function(win)
				trouble.close("quickfix")
			end,
			on_pane_existed = function(win)
				-- Trouble's quickfix and neotest windowns are exclusive to each other for now
				-- Having them both is counterproductive
				-- neotest.output_panel.close()
				require("neotest").summary.close()
				---@diagnostic disable-next-line: missing-fields
				trouble.focus({ mode = "quickfix" }, {})
			end,
			on_pane_not_existed = function()
				-- Trouble's quickfix and neotest windowns are exclusive to each other for now
				-- Having them both is counterproductive
				-- neotest.output_panel.close()
				require("neotest").summary.close()

				-- Trouble's diagnostics and quickfix windows are exclusive to each other for now
				-- Having them both is counterproductive
				trouble.close("diagnostics")
				trouble.open({ mode = "quickfix", focus = true, win = { position = "bottom" } })
			end,
		})
	end, { desc = "Toggle Quickfix" })

	keymap({ "n", "v", "i" }, "<M-3>", function()
		-- keymap({ "n", "v", "i" }, "<C-c>", function()
		panes_util.toggle_pane({
			pane_open_predicate = {
				customtype = function(win)
					local w = vim.w[win.winid].trouble
					if w == nil then
						return false
					end
					return w.mode == "diagnostics"
				end,
			},
			on_pane_is_being_focused = function(win)
				trouble.close("diagnostics")
			end,
			on_pane_existed = function(win)
				-- Trouble's quickfix and neotest windowns are exclusive to each other for now
				-- Having them both is counterproductive
				-- neotest.output_panel.close()
				require("neotest").summary.close()
				---@diagnostic disable-next-line: missing-fields
				trouble.focus({ mode = "diagnostics" }, {})
			end,
			on_pane_not_existed = function()
				-- Trouble's quickfix and neotest windowns are exclusive to each other for now
				-- Having them both is counterproductive
				-- neotest.output_panel.close()
				require("neotest").summary.close()
				trouble.close("quickfix")
				trouble.open({ mode = "diagnostics", focus = true, win = { position = "bottom" } })
			end,
		})
	end, { desc = "Toggle Quickfix" })
	-- keymap({ "n", "v", "i" }, "<M-3>", function()
	-- 	-- keymap({ "n", "v", "i" }, "<C-c>", function()
	-- 	panes_util.toggle_pane({
	-- 		pane_open_predicate = {
	-- 			customtype = function(win)
	-- 				return win.quickfix == 1
	-- 			end,
	-- 		},
	-- 		on_pane_is_being_focused = function(win)
	-- 			vim.cmd("cclose")
	-- 		end,
	-- 		on_pane_existed = function(win)
	-- 			vim.api.nvim_set_current_win(win.winid)
	-- 		end,
	-- 		on_pane_not_existed = function()
	-- 			vim.cmd("copen")
	-- 		end,
	-- 	})
	-- end, { desc = "Toggle Quickfix" })

	-- Navigating between quickfix list
	local function safe_cmd(cmd)
		local ok, err = pcall(vim.cmd, cmd)
		if not ok or err ~= nil then
			vim.notify("No more quickfix items.")
		end
	end
	keymap({ "n", "v", "i" }, "<C-.>", qf.next, { desc = "Next Quickfix Item" })
	keymap({ "n", "v", "i" }, "<C-,>", qf.prev, { desc = "Previous Quickfix Item" })

	keymap({ "n", "v", "i" }, "<C-n>", function()
		dg.next({ buf_only = true })
	end, { desc = "Next In-file diagnostics Item" })
	keymap({ "n", "v", "i" }, "<C-p>", function()
		dg.prev({ buf_only = true })
	end, { desc = "Previous In-fle diagnostics Item" })

	keymap({ "n", "v", "i" }, "<M-n>", dg.next, { desc = "Next Global diagnostics Item" })
	keymap({ "n", "v", "i" }, "<M-p>", dg.prev, { desc = "Previous Global diagnostics Item" })
end
