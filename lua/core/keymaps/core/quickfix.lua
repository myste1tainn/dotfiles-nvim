local keymap = vim.keymap.set
local panes_util = require("utils.panes")
local neotest = require("neotest")

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
--
-- -- Reposition quickfix without stealing focus
-- vim.api.nvim_create_autocmd({ "WinNew", "WinEnter", "WinResized" }, {
-- 	callback = function()
-- 		local current = vim.api.nvim_get_current_win()
-- 		for _, win in ipairs(vim.api.nvim_list_wins()) do
-- 			local buf = vim.api.nvim_win_get_buf(win)
-- 			if vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix" then
-- 				resize_quickfix(win)
-- 				-- Return to where you were
-- 				vim.api.nvim_set_current_win(current)
-- 				break
-- 			end
-- 		end
-- 	end,
-- })
--

-- Force anyone other plugins who try to open the quickfix window to use Trouble instead
local function cabbr(lhs, rhs)
	vim.cmd(
		("cnoreabbrev <expr> %s (getcmdtype()==':' && getcmdline()==#'%s') ? '%s' : '%s'"):format(lhs, lhs, rhs, lhs)
	)
end

cabbr("copen", "Trouble quickfix")
cabbr("cope", "Trouble quickfix")
cabbr("cwindow", "Trouble quickfix")
cabbr("cw", "Trouble quickfix")

local function open_trouble()
	-- Only open when there are items
	if vim.fn.getqflist({ size = 0 }).size > 0 then
		require("trouble").open({
			mode = "quickfix",
			focus = true,
			win = { position = "bottom" },
		})
	end
end

-- 1. Any time a quick-fix window actually opens (no matter who opened it)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf", -- fires for real quick-fix buffers
	callback = function()
		-- run *after* the window finishes opening to avoid closing the buffer we’re in
		vim.schedule(function()
			vim.cmd("cclose") -- close the native qf
			open_trouble() -- show Trouble instead
		end)
	end,
})

-- 2. When a command *only* populates the list (grep, make, etc.) but doesn’t open it
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	pattern = "*",
	callback = function()
		vim.defer_fn(function() -- let the command finish first
			open_trouble()
		end, 20) -- 20 ms guard handles async pop-ups
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
				-- Trouble's quickfix and neotest windowns are exclusive to each other for now
				-- Having them both is counterproductive
				neotest.output_panel.close()
				neotest.summary.close()
				---@diagnostic disable-next-line: missing-fields
				trouble.focus({ mode = "quickfix" }, {})
			end,
			on_pane_not_existed = function()
				-- Trouble's quickfix and neotest windowns are exclusive to each other for now
				-- Having them both is counterproductive
				neotest.output_panel.close()
				neotest.summary.close()

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
				neotest.output_panel.close()
				neotest.summary.close()
				---@diagnostic disable-next-line: missing-fields
				trouble.focus({ mode = "diagnostics" }, {})
			end,
			on_pane_not_existed = function()
				-- Trouble's quickfix and neotest windowns are exclusive to each other for now
				-- Having them both is counterproductive
				neotest.output_panel.close()
				neotest.summary.close()
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
	keymap({ "n", "v", "i" }, "<C-.>", function()
		local current_idx = vim.fn.getqflist({ idx = 0 }).idx
		local total_items = #vim.fn.getqflist()
		if current_idx >= total_items then
			vim.notify("No more quickfix items. Continuing from the top.", vim.log.levels.INFO)
			safe_cmd("cfirst")
		else
			safe_cmd("cnext")
		end
	end, { desc = "Next Quickfix Item" })
	keymap({ "n", "v", "i" }, "<C-,>", function()
		local current_idx = vim.fn.getqflist({ idx = 0 }).idx
		if current_idx <= 1 then
			vim.notify("No previous quickfix items. Continuing from the bottom.", vim.log.levels.INFO)
			safe_cmd("clast")
		else
			safe_cmd("cprev")
		end
	end, { desc = "Previous Quickfix Item" })

	keymap({ "n", "v", "i" }, "<M-.>", function()
		vim.cmd("Trouble diagnostics next")
		vim.cmd("Trouble diagnostics jump")
	end, { desc = "Next Quickfix Item" })
	keymap({ "n", "v", "i" }, "<M-,>", function()
		vim.cmd("Trouble diagnostics prev")
		vim.cmd("Trouble diagnostics jump")
	end, { desc = "Previous Quickfix Item" })
end
