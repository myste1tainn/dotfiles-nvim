local keymap = vim.keymap.set
local panes_util = require("utils.panes")

local function resize_quickfix(win)
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
		vim.cmd("wincmd J")
		vim.cmd("resize 15")
	end
end

-- Always open quickfix window at the bottom
vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function(args)
		if vim.api.nvim_buf_get_option(args.buf, "buftype") == "quickfix" then
			vim.schedule(function()
				resize_quickfix(vim.fn.win_getid())
			end)
		end
	end,
})

-- Reposition quickfix without stealing focus
vim.api.nvim_create_autocmd({ "WinNew", "WinEnter", "WinResized" }, {
	callback = function()
		local current = vim.api.nvim_get_current_win()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix" then
				resize_quickfix(win)
				-- Return to where you were
				vim.api.nvim_set_current_win(current)
				break
			end
		end
	end,
})

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
				---@diagnostic disable-next-line: missing-fields
				trouble.focus({ mode = "quickfix" }, {})
			end,
			on_pane_not_existed = function()
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
				---@diagnostic disable-next-line: missing-fields
				trouble.focus({ mode = "diagnostics" }, {})
			end,
			on_pane_not_existed = function()
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
	keymap({ "n", "v", "i" }, "<C-.>", function()
		local current_idx = vim.fn.getqflist({ idx = 0 }).idx
		local total_items = #vim.fn.getqflist()
		if current_idx >= total_items then
			vim.notify("No more quickfix items. Continuing from the top.", vim.log.levels.INFO)
			vim.cmd("cfirst")
		else
			vim.cmd("cnext")
		end
	end, { desc = "Next Quickfix Item" })
	keymap({ "n", "v", "i" }, "<C-,>", function()
		local current_idx = vim.fn.getqflist({ idx = 0 }).idx
		if current_idx <= 1 then
			vim.notify("No previous quickfix items. Continuing from the bottom.", vim.log.levels.INFO)
			vim.cmd("clast")
		else
			vim.cmd("cprev")
		end
	end, { desc = "Previous Quickfix Item" })
end
