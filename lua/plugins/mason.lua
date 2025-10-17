return {
	"mason-org/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"glepnir/lspsaga.nvim",
		"mfussenegger/nvim-jdtls",
	},
	opts = {},
	config = function()
		require("mason").setup({})
		-- Extract only the server names from the servers table
		local servers = require("lsp.servers")
		local server_names = {}
		for _, server in pairs(servers) do
			-- Change to the name that mason-lspconfig uses
			if server == "dartls" then
				goto continue
			end
			table.insert(server_names, server)
			::continue::
		end

		require("mason-lspconfig").setup({
			ensure_installed = server_names,
			automatic_enable = false,
		})

		require("lspsaga").setup()
	end,
}
