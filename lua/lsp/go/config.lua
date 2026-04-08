vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		-- require("autolist").setup({ enabled = false })
		-- vim.keymap.set("n", "o", "o", { buffer = true }) -- restore normal o
		-- vim.keymap.set("i", "<CR>", "<CR>", { buffer = true }) -- restore normal <CR>
		-- vim.keymap.set("n", "dd", "dd", { buffer = true }) -- restore normal dd
		-- vim.opt_local.shiftwidth = 2
		-- vim.opt_local.tabstop = 2
		-- vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = false
	end,
})

return {
	cmd = { "gopls" },
	on_attach = function(client, bufnr) end,
	root_dir = function(bufnr)
		local path = vim.api.nvim_buf_get_name(bufnr)
		if path == "" then
			return
		end
		local util = require("lspconfig.util")
		return util.root_pattern("go.mod")(path)
			or vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true, path = path })[1])
	end,
	settings = {
		gopls = {
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
