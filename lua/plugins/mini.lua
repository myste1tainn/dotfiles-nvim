return {
	"echasnovski/mini.nvim",
	version = "*",
	config = function() end,
	dependencies = {
		{
			"echasnovski/mini.ai",
			version = "*",
			config = function()
				require("mini.ai").setup()
			end,
		},
		{
			"echasnovski/mini.align",
			version = "*",
			config = function()
				require("mini.align").setup()
			end,
		},
		{
			"echasnovski/mini.splitjoin",
			version = "*",
			config = function()
				require("mini.splitjoin").setup()
			end,
		},
		{
			"echasnovski/mini.surround",
			version = "*",
			config = function()
				require("mini.surround").setup({
					mappings = {
						add = "fa", -- Add surrounding in Normal and Visual modes
						delete = "fd", -- Delete surrounding
						find = "ff", -- Find surrounding (to the right)
						find_left = "fF", -- Find surrounding (to the left)
						highlight = "fh", -- Highlight surrounding
						replace = "fr", -- Replace surrounding
						update_n_lines = "fn", -- Update `n_lines`
						suffix_last = "l", -- Suffix to search with "prev" method
						suffix_next = "n", -- Suffix to search with "next" method
					},
				})
			end,
		},
		{
			"echasnovski/mini.pairs",
			version = "*",
			config = function()
				require("mini.pairs").setup()
			end,
		},
		{
			"echasnovski/mini.comment",
			version = "*",
			config = function()
				require("mini.comment").setup()
			end,
		},
		{
			"echasnovski/mini.indentscope",
			version = "*",
			config = function()
				require("mini.indentscope").setup({
					draw = {
						animation = require("mini.indentscope").gen_animation.none(),
						delay = 0,
					},
					mappings = {
						goto_top = "",
						goto_bottom = "",
					}, -- NOTE: Disable default mappings, this conflicts with mini.bracketed
				})
			end,
		},
	},
}
