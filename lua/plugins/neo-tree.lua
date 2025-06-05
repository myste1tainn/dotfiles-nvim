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
			buffers = { follow_current_file = { enabled = false } },
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = true,
				},
				follow_current_file = { enabled = false },
				use_libuv_file_watcher = true,
				window = {
					mappings = {
						["o"] = "system_open",
					},
				},
			},
			commands = {
				-- NOTE: Disable because it wrong, the code itself is suggested by the plugin official page
				---@diagnostic disable-next-line: redundant-parameter
				system_open = function(state)
					local node = state.tree:get_node()
					if node.type == "directory" then
						vim.fn.system("open " .. node.path)
					else
						vim.fn.system("open " .. vim.fn.fnameescape(node.path))
					end
				end,
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
