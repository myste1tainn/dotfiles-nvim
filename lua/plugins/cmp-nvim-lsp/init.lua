return {
	"hrsh7th/cmp-nvim-lsp",
	config = function()
		require("plugins.cmp-nvim-lsp.setup")
		require("lsp.setup")
	end,
}
