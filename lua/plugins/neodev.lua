-- TODO: neodev is being setup twice, once in lsp.lua and once here. Check if this is necessary.
return {
	"folke/neodev.nvim",
	lazy = false,
	config = function()
		require("neodev").setup({})
	end,
}
