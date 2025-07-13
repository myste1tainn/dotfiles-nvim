vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		require("autolist").setup({ enabled = false }) -- if supported
		vim.keymap.set("n", "dd", "dd", { buffer = true }) -- restore normal dd
	end,
})

return {
	on_attach = function(client, bufnr) end,
	root_dir = function(fname)
		local util = require("lspconfig.util")
		return util.root_pattern("go.mod")(fname) or util.find_git_ancestor(fname)
	end,
	settings = {
		gopls = {
			flags = {
				debounce_text_changes = 300,
			},
			diagnosticsDelay = "300ms",
			gofumpt = true,
			usePlaceholders = true,
			completeUnimported = true,
			staticcheck = true,
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
}
