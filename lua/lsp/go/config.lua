return {
	on_attach = function(client, bufnr)
		-- Keymaps for Go
	end,
	root_dir = function(fname)
		local util = require("lspconfig.util")
		return util.root_pattern("go.mod")(fname) or util.find_git_ancestor(fname)
	end,
	settings = {
		gopls = {
			gofumpt = true,
			usePlaceholders = true,
			completeUnimported = true, -- <<< This is the key
			staticcheck = true,
		},
	},
}
