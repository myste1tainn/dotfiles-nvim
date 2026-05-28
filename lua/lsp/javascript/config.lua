local unpack = table.unpack or unpack

local root_files = {
	"package.json",
	"tsconfig.json",
	"jsconfig.json",
	".git",
}

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "typescript", "typescriptreact", "javascript" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.expandtab = true
	end,
})

return {
	cmd = { vim.fn.expand("$HOME/.local/share/nvim/mason/bin/typescript-language-server"), "--stdio" },
	on_attach = function(client, bufnr)
		-- Keymaps for JavaScript
	end,
	root_dir = function(bufnr)
		local path = vim.api.nvim_buf_get_name(bufnr)
		-- pyright looks for pyrightconfig.json in the parent dir of the python path,
		-- so the venv dir itself must not be used as the root.
		return require("lspconfig.util").root_pattern(unpack(root_files))(path)
	end,
}
