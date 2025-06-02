return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"glepnir/lspsaga.nvim",
	},
	opts = {},
	config = function()
		require("mason").setup({})
		-- Extract only the server names from the servers table
		local servers = require("lsp.servers")
		local server_names = {}
		for _, server in pairs(servers) do
			table.insert(server_names, server)
		end

		require("mason-lspconfig").setup({
			ensure_installed = server_names,
			automatic_enable = false,
		})

		require("lspsaga").setup()
	end,
}
