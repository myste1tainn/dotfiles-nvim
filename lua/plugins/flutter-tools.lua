return {
	"nvim-flutter/flutter-tools.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim", -- optional for vim.ui.select
	},
	config = true,
	opts = {
		lsp = {
			capabilities = function(config)
				config.workspace = config.workspace or {}
				config.workspace.workspaceEdit = {
					documentChanges = true,
					resourceOperations = { "create", "rename", "delete" }, -- important for rename
					failureHandling = "abort",
				}
				config.textDocument = config.textDocument or {}
				config.textDocument.rename = { dynamicRegistration = true, prepareSupport = true }

				return config
			end,
		},
	},
}
