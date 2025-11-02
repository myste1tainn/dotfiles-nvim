local lspconfig = require("lspconfig")

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "dart" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		-- vim.opt_local.expandtab = true

		-- Disable autolist for dart files, because it interferes with flutter widget editing
		-- require("autolist").setup({ enabled = false })
		-- vim.keymap.set("n", "o", "o", { buffer = true }) -- restore normal o
		-- vim.keymap.set("i", "<CR>", "<CR>", { buffer = true }) -- restore normal <CR>
		-- vim.keymap.set("n", "dd", "dd", { buffer = true }) -- restore normal dd
	end,
})

return {
	cmd = { "dart", "language-server", "--protocol=lsp" },
	filetypes = { "dart" },
	root_dir = function(fname)
		return lspconfig.util.root_pattern("pubspec.yaml")(fname)
	end,
	-- init_options = {
	-- },
	settings = {
		dart = {
			completeFunctionCalls = true,
			closingLabels = true,
			outline = true,
			onlyAnalyzeProjectsWithOpenFiles = true,
			flutterOutline = true,
			suggestFromUnimportedLibraries = true,
		},
	},
	-- on_attach etc
}
