local M = {}
M.ratios = {}

-- Save current window ratios
function M.save_ratios()
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local total_cols = vim.o.columns
	local total_lines = vim.o.lines - vim.o.cmdheight - 1

	for _, win in ipairs(wins) do
		local cfg = vim.api.nvim_win_get_config(win)
		if cfg.relative == "" then
			M.ratios[win] = {
				width = vim.api.nvim_win_get_width(win) / total_cols,
				height = vim.api.nvim_win_get_height(win) / total_lines,
			}
			-- print(
			-- 	"Saving win",
			-- 	win,
			-- 	"with ratio",
			-- 	M.ratios[win],
			-- 	"width:",
			-- 	M.ratios[win].width,
			-- 	"height:",
			-- 	M.ratios[win].height
			-- )
		end
	end
end

-- Restore window sizes based on stored ratios
function M.restore_ratios()
	local total_cols = vim.o.columns
	local total_lines = vim.o.lines - vim.o.cmdheight - 1

	local wins = vim.api.nvim_tabpage_list_wins(0)

	-- Step 1: Build row groups (vertical layout detection)
	table.sort(wins, function(a, b)
		local a_pos = vim.api.nvim_win_get_position(a)
		local b_pos = vim.api.nvim_win_get_position(b)
		return a_pos[2] < b_pos[2] -- y position
	end)

	for _, win in ipairs(wins) do
		if vim.api.nvim_win_is_valid(win) and M.ratios[win] then
			local ratio = M.ratios[win]

			local height = math.max(5, math.floor(total_lines * ratio.height))
			local width = math.max(20, math.floor(total_cols * ratio.width))

			-- print("restoring win", win, "with ratio", ratio, "to height", height, "and width", width)
			-- Prefer setting height *before* width if it's a bottom split
			local row = vim.api.nvim_win_get_position(win)[2]
			if row > total_lines / 2 then
				pcall(vim.api.nvim_win_set_height, win, height)
				pcall(vim.api.nvim_win_set_width, win, width)
			else
				pcall(vim.api.nvim_win_set_width, win, width)
				pcall(vim.api.nvim_win_set_height, win, height)
			end
		end
	end
end

-- Setup autocommands
function M.setup()
	-- Save ratios on win events
	vim.api.nvim_create_autocmd({ "WinEnter", "WinNew", "WinClosed", "WinResized", "BufWinEnter" }, {
		callback = function()
			vim.defer_fn(M.save_ratios, 50)
		end,
	})

	-- Reapply ratios on terminal resize
	vim.api.nvim_create_autocmd("VimResized", {
		callback = function()
			vim.defer_fn(M.restore_ratios, 50)
		end,
	})
end

return M
