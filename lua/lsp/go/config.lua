return {
	on_attach = function(client, bufnr)
		-- Keymaps for Go
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
