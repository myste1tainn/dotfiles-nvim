vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = false,
	underline = true,
})

-- get neotest namespace (api call creates or returns namespace)
local neotest_ns = vim.api.nvim_create_namespace("neotest")
vim.diagnostic.config({
	virtual_text = {
		format = function(diagnostic)
			local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
			return message
		end,
	},
}, neotest_ns)

-- TODO: Comment out for now, because it interferes with other function using quickfix, find a better way to handle this
-- vim.api.nvim_create_autocmd("DiagnosticChanged", {
-- 	callback = function()
-- 		local bufnr = vim.api.nvim_get_current_buf()
-- 		-- if there are no diagnostics, don't set it
-- 		local diagnostics = vim.diagnostic.get(bufnr)
-- 		if #diagnostics == 0 then
-- 			return
-- 		end
-- 		vim.diagnostic.setqflist({ open = false }, bufnr)
-- 	end,
-- })

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
