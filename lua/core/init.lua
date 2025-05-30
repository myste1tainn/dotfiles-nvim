-- call to capabilities that based on LSP
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		require("core.diagnostics")(args.buf)
	end,
})
