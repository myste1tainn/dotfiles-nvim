return {
	on_attach = function(client, bufnr) end,
	-- root_dir = function(fname)
	-- 	local util = require("lspconfig.util")
	-- 	return util.root_pattern("go.mod")(fname) or util.find_git_ancestor(fname)
	-- end,
	settings = {
		rust_analyzer = {
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
