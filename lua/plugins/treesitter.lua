-- Setup for nvim-treesitter
return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		run = ":TSUpdate",
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "go", "python", "dart", "lua", "javascript", "rust", "starlark" },
				highlight = {
					enable = true,
				},
				indent = {
					enable = true,
					disable = { "dart" },
				},
				-- NOTE: Commented out to avoid conflicts with mini.ai
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
						},
					},
				},
			})
		end,
	},
}
