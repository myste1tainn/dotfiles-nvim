return {
	cmd = { "plantuml-lsp", "--exec-path=plantuml" },
	filetypes = { "plantuml" },
	root_dir = function(bufnr)
		local path = vim.api.nvim_buf_get_name(bufnr)
		if path == "" then
			return
		end

		return vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true, path = path })[1]) or vim.fs.dirname(path)
	end,
}
