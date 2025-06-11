-- Setup for gruvbox.nvim
return {
	{
		"ellisonleao/gruvbox.nvim",
		lazy = true,
		config = function()
			-- Set the colorscheme to gruvbox
			require("gruvbox").setup({
				undercurl = true, -- enable undercurl
				underline = true, -- enable underline
				bold = true, -- enable bold text
				italic = {
					strings = true, -- enable italic for strings
					comments = true, -- enable italic for comments
					operators = false, -- disable italic for operators
					folds = false, -- disable italic for folds
					emphasis = true,
				},
				strikethrough = true, -- enable strikethrough
				invert_selection = false, -- disable inverted selection
				contrast = "dark", -- set contrast level to soft
				overrides = {}, -- custom overrides for specific highlight groups
			})
		end,
	},
	{
		"chriskempson/base16-vim",
		-- base16-default-dark
		name = "base16",
		lazy = true,
		priority = 1000,
	},
	{
		"ayu-theme/ayu-vim",
		name = "ayu",
		lazy = true,
		priority = 1000,
	},
	{
		"uloco/bluloco.nvim",
		name = "bluloco",
		lazy = true,
		priority = 1000,
		dependencies = { "rktjmp/lush.nvim" },
		config = function()
			require("bluloco").setup({
				style = "auto", -- "auto" | "dark" | "light"
				transparent = false,
				italics = false,
				terminal = vim.fn.has("gui_running") == 1, -- bluoco colors are enabled in gui terminals per default.
				guicursor = true,
				rainbow_headings = false, -- if you want different colored headings for each heading level
			})
		end,
	},
	-- {
	-- 	"rafi/awesome-vim-colorschemes",
	-- 	name = "awesome-colorschemes",
	-- 	lazy = true,
	-- 	priority = 1000,
	-- },
	{
		"loctvl842/monokai-pro.nvim",
		name = "monokai-pro",
		lazy = true,
		priority = 1000,
	},
	{
		"arcticicestudio/nord-vim",
		name = "nord-vim",
		lazy = true,
		priority = 1000,
	},
	{
		"EdenEast/nightfox.nvim",
		name = "nightfox",
		lazy = true,
		priority = 1000,
	},
	{
		"connorholyday/vim-snazzy",
		name = "snazzy",
		lazy = true,
		priority = 1000,
	},
}
