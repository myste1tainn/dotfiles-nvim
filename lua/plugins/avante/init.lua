return {
	"yetone/avante.nvim",
	config = function()
		require("avante").setup({
			provider = "openai",
			auto_suggestions_provider = "openai",
			api_key = os.getenv("OPENAI_API_KEY"),
			openai = {
				model = "gpt-4o",
			},
			layout = {
				default = "ide", -- options: "ide", "minimal"
				width = 0.2, -- width of sidebar (float from 0 to 1)
				position = "bottom", -- "left" or "right"
			},
		})
		require("plugins.avante.keymap")
	end,
	build = "make",
	event = "VeryLazy",
	version = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = { file_types = { "markdown", "Avante" } },
			ft = { "markdown", "Avante" },
		},
		{
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = { insert_mode = true },
					use_absolute_path = true,
				},
			},
		},
	},
}
