return {
	cmd = { "groovy-language-server" },
	filetypes = { "groovy", "java" },
	root_dir = function(fname)
		return vim.fs.dirname(
			vim.fs.find({ "build.gradle", "settings.gradle", ".git" }, { upward = true, path = fname })[1]
		)
	end,
	settings = {},
}
