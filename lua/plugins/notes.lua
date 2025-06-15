return {
	-- Obsidian.nvim for vaults and linking
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = true,
		event = { "BufReadPre ~/vaults/**.md" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			workspaces = {
				{
					name = "personal",
					path = "~/vaults/personal",
				},
				{
					name = "work",
					path = "~/vaults/work",
				},
			},
			completion = {
				nvim_cmp = true,
			},
		},
	},

	-- Telekasten for daily notes and templates
	{
		"renerocksai/telekasten.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("telekasten").setup({
				home = vim.fn.expand("~/vaults/personal"),
				dailies = "daily",
				weeklies = "weekly",
				templates = "templates",
			})
		end,
	},

	-- Markdown preview (for Mermaid support)
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		ft = { "markdown" },
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
	},

	-- ChatGPT integration for markdown assistance
	{
		"jackMort/ChatGPT.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("chatgpt").setup({})
		end,
	},

	-- Optional: zk for fast note search and backlinks
	{
		"mickael-menu/zk-nvim",
		config = function()
			require("zk").setup({
				picker = "telescope",
			})
		end,
	},
}
