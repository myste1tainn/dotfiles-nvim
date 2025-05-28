return {
	"hrsh7th/cmp-buffer",
	dependencies = {
		"hrsh7th/nvim-cmp",
	},
	config = function()
		require("plugins.cmp-buffer.setup")
	end,
}
