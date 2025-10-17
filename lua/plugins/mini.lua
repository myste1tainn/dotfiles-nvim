return {
	"echasnovski/mini.nvim",
	version = "*",
	config = function() end,
	dependencies = {
		{
			"echasnovski/mini.align",
			version = "*",
			config = function()
				require("mini.align").setup()
			end,
		},
		{
			"echasnovski/mini.move",
			version = "*",
			config = function()
				require("mini.move").setup({
					mappings = {
						left = "<C-h>",
						right = "<C-l>",
						down = "<C-j>",
						up = "<C-k>",
						line_left = "<C-h>",
						line_right = "<C-l>",
						line_down = "<C-j>",
						line_up = "<C-k>",
						block_left = "<C-h>",
						block_right = "<C-l>",
						block_down = "<C-j>",
						block_up = "<C-k>",
					},
				})
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
