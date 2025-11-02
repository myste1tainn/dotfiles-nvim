vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua" },
	callback = function()
		-- vim.opt_local.shiftwidth = 2
		-- vim.opt_local.tabstop = 2
		-- vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = false
	end,
})

return {
	on_attach = function(client, bufnr)
		-- Keymaps for Lua
	end,
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
}
