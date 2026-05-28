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

local server_to_config = {}
-- TODO: Find a way to do this from within mason-lspconfig
-- Setup each language server
for lang, server in pairs(mason_servers) do
	if lang == "lua" then
		require("neodev").setup()
	end

	local config = require("lsp." .. lang .. ".config")
	config.settings = config.settings or {}
	for _, opts in pairs(config.settings or {}) do
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

	-- -- require("lspconfig")[server].setup(final_config)
	-- if lang == "starlark" then
	-- 	server = "tilt_ls"
	-- 	-- Original value can be see in the servers.lua, but in my case
	-- 	-- I just want to use it with tilt for now, not the whole starlark language
	-- end
	vim.lsp.config(server, final_config)
	vim.lsp.enable(server)
	server_to_config[server] = final_config
end

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		local exlude_filetypes = {
			"markdown",
			"text",
			"gitcommit",
			"notify",
			"toggleterm",
			"noice",
			"TelescopeResults",
			"TelescopePrompt",
			"OverseerOutput",
			"OverseerList",
			"NeogitPopup",
			"Avante",
			"AvanteInput",
			"AvanteTodos",
			"AvanteSelectedFiles",
			"NeogitCommitMessage",
			"NeogitConsole",
			"neo-tree",
			"lazy",
			"lazy_backdrop",
			"cmp_docs",
		}
		if vim.tbl_contains(exlude_filetypes, vim.bo.filetype) then
			return
		end

		local server = mason_servers[vim.bo.filetype]
		if not server then
			-- For the case that I know the filetype will not matched the server name in the mason_servers, I will hardcode the mapping here
			if vim.bo.filetype == "typescript" then
				server = mason_servers["javascript"]
			elseif vim.bo.filetype == "javascriptreact" then
				server = mason_servers["javascript"]
			elseif vim.bo.filetype == "typescriptreact" then
				server = mason_servers["javascript"]
			else
				print("No LSP server configured for filetype " .. vim.bo.filetype)
				return
			end
		end

		local final_config = server_to_config[server]
		-- prevent duplicate attach
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
			if client.name == server then
				return
			end
		end

		local root
		if type(final_config.root_dir) == "function" then
			root = final_config.root_dir(ev.buf)
		else
			root = final_config.root_dir
		end

		if not root then
			print("No root directory found for " .. server .. " in buffer " .. ev.buf)
			return -- no root found, don't start
		end

		-- if vim.bo.filetype == "javascript" then
		-- 	print("Starting LSP server " .. server .. " for filetype " .. vim.bo.filetype .. " in buffer " .. ev.buf)
		-- 	print("Final config passed to lsp.start: " .. vim.inspect(final_config))
		-- end

		-- Pass the full registered config so per-language on_attach, settings,
		-- before_init, capabilities, etc. are honored. Override name and root_dir
		-- with values resolved here.
		local start_config = vim.tbl_extend("force", final_config, {
			name = server,
			root_dir = root,
		})
		vim.lsp.start(start_config)
	end,
})
