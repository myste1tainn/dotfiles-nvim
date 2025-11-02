-- Central LSP setup file

-- Inform the linter that `vim` is a global variable provided by Neovim
---@diagnostic disable: undefined-global

-- Disable signature help handler, because I'm using lsp_signature.nvim
vim.lsp.handlers["textDocument/signatureHelp"] = function() end
-- Enable inlay hints for all LSP servers
vim.lsp.inlay_hint.enable()
-- Default capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.inlayHint = { dynamicRegistration = false }

-- List of language servers and their specific configurations
-- Import the list of servers from mason configuration
local mason_servers = require("lsp.servers")

-- TODO: Find a way to do this from within mason-lspconfig
-- Setup each language server
for lang, server in pairs(mason_servers) do
	if lang == "lua" then
		require("neodev").setup()
	elseif lang == "starlark" then
		vim.lsp.enable("tilt_ls")
		-- Original value can be see in the servers.lua, but in my case
		-- I just want to use it with tilt for now, not the whole starlark language
		server = "tilt_ls"
	end
	-- print("Setting up LSP server for " .. lang .. ": " .. server)
	-- vim.lsp.config(server, final_config)
	-- vim.lsp.enable(server)
	local config = require("lsp." .. lang .. ".config")
	config.settings = config.settings or {}
	for lang, opts in pairs(config.settings or {}) do
		if type(opts) == "table" then
			opts.semanticTokens = true
		end
	end
	local final_config = vim.tbl_deep_extend("force", {
		flags = {
			debounce_text_changes = 400,
		},
		capabilities = capabilities,
	}, config)
	require("lspconfig")[server].setup(final_config)
end
