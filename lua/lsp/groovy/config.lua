return {
	cmd = { "groovy-language-server" },
	filetypes = { "groovy", "java" },
	root_dir = function(bufnr)
		local path = vim.api.nvim_buf_get_name(bufnr)
		if path == "" then
			return
		end

		return vim.fs.dirname(
			vim.fs.find({ "build.gradle", "settings.gradle", ".git" }, { upward = true, path = path })[1]
		)
	end,
	settings = {},
}
