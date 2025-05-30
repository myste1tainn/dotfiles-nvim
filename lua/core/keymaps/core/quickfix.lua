local keymap = vim.keymap.set

return function(bufnr)
	-- Toggling Quickfix
	keymap({ "n", "v", "i" }, "<C-c>", function()
		local quickfix_open = false
		for _, win in ipairs(vim.fn.getwininfo()) do
			if win.quickfix == 1 then
				quickfix_open = true
				if win.tabnr == vim.fn.tabpagenr() then
					if vim.api.nvim_get_current_win() == win.winid then
						vim.cmd("cclose")
					else
						vim.api.nvim_set_current_win(win.winid)
					end
					return
				end
			end
		end
		if not quickfix_open then
			vim.cmd("copen")
		else
			vim.cmd("copen")
		end
	end, { desc = "Toggle Quickfix" })

	-- Navigating between quickfix list
	keymap({ "n", "v", "i" }, "<M-n>", "<Esc>:cnext<CR>", { desc = "Next Quickfix Item" })
	keymap({ "n", "v", "i" }, "<M-p>", "<Esc>:cprev<CR>", { desc = "Previous Quickfix Item" })
end
