return {
	"hrsh7th/cmp-nvim-lsp",
	config = function()
		-- TODO: Refactor and combine into nvim-cmp setup and make mason part of its dependencies
		require("lsp.setup")
		require("core.diagnostics")()
	end,
}
