local keymap = vim.keymap.set
local wins = require("utils.wins")

-- Generic filtered window iteration
local function for_normal_windows(fn)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
		local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
		if bt == "" and not wins.keep_filetypes[ft] then
			fn(win)
		end
	end
end

vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function()
		vim.defer_fn(function()
			local win = vim.api.nvim_get_current_win()
			if vim.api.nvim_win_get_option(win, "diff") then
				if vim.w._diff_keymaps_set then
					return
				end
				vim.w._diff_keymaps_set = true

				local function diffget_both(order)
					local cmd = (order == "ours_first") and "diffget LOCAL | normal! j | diffget REMOTE"
						or "diffget REMOTE | normal! j | diffget LOCAL"
					vim.cmd(cmd)
				end

				-- NOTE: This conflicts with diffview.nvim, but if you found a way to use it, then this is not necessary anymore
				-- local opts = { buffer = 0, desc = "" }
				-- vim.keymap.set({ "n", "v" }, "<leader>cbo", function()
				-- 	diffget_both("ours_first")
				-- end, vim.tbl_extend("force", opts, { desc = "Diffget both (ours first)" }))
				--
				-- vim.keymap.set({ "n", "v" }, "<leader>cbt", function()
				-- 	diffget_both("theirs_first")
				-- end, vim.tbl_extend("force", opts, { desc = "Diffget both (theirs first)" }))
				--
				-- vim.keymap.set({ "n", "v" }, "<leader>co", function()
				-- 	vim.cmd("diffget 2")
				-- end, vim.tbl_extend("force", opts, { desc = "Diffget LOCAL (ours)" }))
				--
				-- vim.keymap.set({ "n", "v" }, "<leader>ct", function()
				-- 	vim.cmd("diffget 3")
				-- end, vim.tbl_extend("force", opts, { desc = "Diffget REMOTE (theirs)" }))
			end
		end, 100)
	end,
})

return function(bufnr)
	keymap({ "n", "v" }, "<leader>dd", function()
		for_normal_windows(function(win)
			vim.api.nvim_set_current_win(win)
			vim.cmd("diffthis")
		end)
	end, { desc = "Git diff (filtered)" })

	keymap({ "n", "v" }, "<leader>dx", function()
		for_normal_windows(function(win)
			vim.api.nvim_set_current_win(win)
			vim.cmd("diffoff")
		end)
	end, { desc = "Git diff off (filtered)" })

	keymap({ "n", "v" }, "<leader>sb", function()
		for_normal_windows(function(win)
			vim.api.nvim_set_current_win(win)
			vim.cmd("setlocal scrollbind")
		end)
	end, { desc = "Scrollbind on (filtered)" })

	keymap({ "n", "v" }, "<leader>so", function()
		for_normal_windows(function(win)
			vim.api.nvim_set_current_win(win)
			vim.cmd("setlocal noscrollbind")
		end)
	end, { desc = "Scrollbind off (filtered)" })

	local function diffget_both(order)
		-- order: "ours_first" or "theirs_first"
		local cmd = (order == "ours_first") and "diffget 2 | normal! j | diffget 3"
			or "diffget 3 | normal! j | diffget 2"
		vim.cmd(cmd)
	end
end
