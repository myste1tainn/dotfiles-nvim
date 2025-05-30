-- Central LSP setup file

-- Inform the linter that `vim` is a global variable provided by Neovim
---@diagnostic disable: undefined-global

-- Default capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- List of language servers and their specific configurations
-- Import the list of servers from mason configuration
local mason_servers = require("lsp.servers")

-- Setup each language server
for lang, server in pairs(mason_servers) do
	local config = require("lsp." .. lang .. ".config")
	local final_config = vim.tbl_deep_extend("force", {
		capabilities = capabilities,
	}, config)
	if lang == "lua" then
		require("neodev").setup()
	end
	require("lspconfig")[server].setup(final_config)
end
