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

return function(bufnr)
	keymap({ "n", "v" }, "<leader>dd", function()
		for_normal_windows(function(win)
			vim.api.nvim_set_current_win(win)
			vim.cmd("diffthis")
		end)
	end, { desc = "Git diff (filtered)" })

	keymap({ "n", "v" }, "<leader>do", function()
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
end
