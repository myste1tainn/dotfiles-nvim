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
	keymap({ "n", "v", "i" }, "<M-n>", function()
		local current_idx = vim.fn.getqflist({ idx = 0 }).idx
		local total_items = #vim.fn.getqflist()
		if current_idx >= total_items then
			vim.notify("No more quickfix items. Continuing from the top.", vim.log.levels.INFO)
			vim.cmd("cfirst")
		else
			vim.cmd("cnext")
		end
	end, { desc = "Next Quickfix Item" })
	keymap({ "n", "v", "i" }, "<M-p>", function()
		local current_idx = vim.fn.getqflist({ idx = 0 }).idx
		if current_idx <= 1 then
			vim.notify("No previous quickfix items. Continuing from the bottom.", vim.log.levels.INFO)
			vim.cmd("clast")
		else
			vim.cmd("cprev")
		end
	end, { desc = "Previous Quickfix Item" })
end
