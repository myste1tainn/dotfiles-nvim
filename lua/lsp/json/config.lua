return {
	cmd = { "vscode-json-language-server", "--stdio" },
	on_attach = function(client, bufnr) end,
	root_dir = function(bufnr)
		local path = vim.api.nvim_buf_get_name(bufnr)
		if path == "" then
			return
		end

		return vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true, path = path })[1])
	end,
}
