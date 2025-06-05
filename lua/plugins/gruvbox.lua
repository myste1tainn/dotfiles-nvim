-- Setup for gruvbox.nvim
return {
	{
		"ellisonleao/gruvbox.nvim",
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
			vim.cmd([[colorscheme gruvbox]])
		end,
	},
}
