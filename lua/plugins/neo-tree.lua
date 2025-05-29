return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			window = { position = "left", width = 30 },
			buffers = { follow_current_file = { enabled = true } },
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = true,
				},
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
			},
			default_component_configs = {
				diagnostics = {
					symbols = {
						hint = "",
						info = "",
						warn = "",
						error = "",
					},
				},
			},
		})
		local keymap = vim.keymap.set

		keymap("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle File Tree", silent = true })
		keymap("n", "<leader>o", ":Neotree reveal<CR>", { desc = "Reveal in File Tree", silent = true })
	end,
}
