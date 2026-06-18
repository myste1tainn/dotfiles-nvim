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

-- ft_to_server and server_to_config are both built from servers.lua entries.
-- An entry is either a plain server name string (filetypes = { lang }) or a
-- table { server = "...", filetypes = { ... } } for multi-filetype servers.
local ft_to_server = {}
local server_to_config = {}

for lang, entry in pairs(mason_servers) do
	if lang == "lua" then
		require("neodev").setup()
	end

	local server = type(entry) == "string" and entry or entry.server
	local filetypes = type(entry) == "string" and { lang } or entry.filetypes

	local config = require("lsp." .. lang .. ".config")
	config.settings = config.settings or {}
	for _, opts in pairs(config.settings or {}) do
		if type(opts) == "table" then
			opts.semanticTokens = true
		end
	end
	local final_config = vim.tbl_deep_extend("force", {
		flags = { debounce_text_changes = 400 },
		capabilities = capabilities,
	}, config)

	vim.lsp.config(server, final_config)
	vim.lsp.enable(server)
	server_to_config[server] = final_config

	for _, ft in ipairs(filetypes) do
		ft_to_server[ft] = server
	end
end

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		local buf = ev.buf
		local ft = vim.bo[buf].filetype

		-- Any non-empty buftype (terminal, quickfix, nofile, prompt, …) means
		-- this is a plugin/UI buffer — skip without inspecting the filetype.
		if vim.bo[buf].buftype ~= "" then
			return
		end

		local server = ft_to_server[ft]
		if not server then
			return
		end

		local final_config = server_to_config[server]
		-- prevent duplicate attach
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
			if client.name == server then
				return
			end
		end

		local root
		if type(final_config.root_dir) == "function" then
			root = final_config.root_dir(buf)
		else
			root = final_config.root_dir
		end

		if not root then
			return
		end

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
