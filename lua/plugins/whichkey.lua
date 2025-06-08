return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		plugins = {
			marks = true, -- shows a list of your marks on '"'
			registers = true, -- shows your registers on '"'
			spelling = {
				enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
				suggestions = 20, -- how many suggestions should be shown in the list?
			},
		},
		window = {
			border = "single", -- none, single, double, shadow
			position = "bottom", -- bottom, top
			margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
			padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
			winblend = 0,
		},
		layout = {
			height = { min = 4, max = 25 }, -- min and max height of the columns
			width = { min = 20, max = 50 }, -- min and max width of the columns
			spacing = 3, -- spacing between columns
			align = "center", -- align columns left, center or right
		},
		hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:" }, -- hide mapping boilerplate
		show_help = true, -- show help message on the command line when the popup is visible
		triggers = "auto", -- automatically setup triggers
		-- triggers = {"<leader>"} -- or specify a list manually
	},
}
