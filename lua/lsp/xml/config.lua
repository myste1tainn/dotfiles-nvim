vim.api.nvim_create_autocmd("FileType", {
	pattern = { "xml", "xsd", "wsdl", "xsl", "xslt" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = true
	end,
})
return {
	filetypes = { "xml", "xsd", "wsdl", "xsl", "xslt" },
	root_dir = function(fname)
		return vim.fs.dirname(
			vim.fs.find({ "build.gradle", "settings.gradle", ".git" }, { upward = true, path = fname })[1]
		)
	end,
	settings = {},
}
