vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = false,
	underline = true,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function()
		-- if there are no diagnostics, don't set it
		local diagnostics = vim.diagnostic.get(0)
		if #diagnostics == 0 then
			return
		end
		vim.diagnostic.setqflist({ open = false })
	end,
})

-- Set CursorHold delay to 100ms
vim.o.updatetime = 100

return function(bufnr)
	vim.api.nvim_create_autocmd("CursorMoved", {
		callback = function()
			vim.diagnostic.open_float(nil, {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "cursor",
			})
		end,
	})
end
