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
