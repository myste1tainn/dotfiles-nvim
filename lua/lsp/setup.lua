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
	local config = require("lsp." .. lang .. ".config")
	local final_config = vim.tbl_deep_extend("force", {
		capabilities = capabilities,
	}, config)
	if lang == "lua" then
		require("neodev").setup()
	elseif lang == "starlark" then
		vim.lsp.enable("tilt_ls")
		-- Original value can be see in the servers.lua, but in my case
		-- I just want to use it with tilt for now, not the whole starlark language
		server = "tilt_ls"
	end
	require("lspconfig")[server].setup(final_config)
end

-- NOTE: Dart is special because it uses a custom plugin
-- Setup dartls with flutter-tools, so there's no module lsp/dart/config.lua
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "dart" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = true

		-- Disable autolist for dart files, because it interferes with flutter widget editing
		require("autolist").setup({ enabled = false })
		vim.keymap.set("n", "o", "o", { buffer = true }) -- restore normal o
		vim.keymap.set("i", "<CR>", "<CR>", { buffer = true }) -- restore normal <CR>
		vim.keymap.set("n", "dd", "dd", { buffer = true }) -- restore normal dd
	end,
})
