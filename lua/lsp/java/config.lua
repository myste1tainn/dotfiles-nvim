local jdtls = require("jdtls")
vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function()
		-- Set Java-specific options
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = true
	end,
})
return {
	on_attach = function(client, bufnr) end,
	settings = { java = {} },
	root_dir = jdtls.setup.find_root({
		"pom.xml",
		"build.gradle",
		".git",
	}),
	init_options = {
		extendedClientCapabilities = jdtls.extendedClientCapabilities,
	},
}
