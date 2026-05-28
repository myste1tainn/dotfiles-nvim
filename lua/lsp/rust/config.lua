return {
	cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/rust-analyzer") },
	on_attach = function(client, bufnr) end,
	root_dir = function(bufnr)
		local path = vim.api.nvim_buf_get_name(bufnr)
		if path == "" then
			vim.notify("Could not get path for buffer " .. path .. " LSP sever will not be started")
			return
		end
		return require("lspconfig.util").root_pattern("Cargo.toml")(path)
			or vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true, path = path })[1])
	end,
	settings = {
		rust_analyzer = {
			flags = {
				debounce_text_changes = 300,
			},
			diagnosticsDelay = "300ms",
			gofumpt = true,
			usePlaceholders = true,
			completeUnimported = true,
			staticcheck = true,
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
}
