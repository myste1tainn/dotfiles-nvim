local panes_util = require("utils.panes")
return {
	"yetone/avante.nvim",
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("avante").setup({
			provider = "copilot",
			-- provider = "openai",
			auto_suggestions_provider = "copilot",
			-- auto_suggestions_provider = "openai",
			api_key = os.getenv("OPENAI_API_KEY"),
			providers = {
				openai = {
					-- model = "gpt-4o-mini",
					-- model = "gpt-4o",
					model = "gpt-4.1",
				},
			},
			dual_boost = {
				enabled = true,
				first_provider = "openai",
				second_provider = "copilot",
				prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
				timeout = 60000, -- Timeout in milliseconds
			},
			behaviour = {
				auto_suggestions = false, -- Experimental stage
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				auto_apply_diff_after_generation = false,
				support_paste_from_clipboard = true,
				minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
				enable_token_counting = true, -- Whether to enable token counting. Default to true.
			},
			windows = {
				position = "bottom",
				-- position = "right",
				-- position = "smart",
				-- input = {
				-- 	width = 60,
				-- },
			},
			mappings = {
				suggestion = {
					accept = "<M-l>",
					next = "<M-.>",
					prev = "<M-,>",
					dismiss = "<M-e>",
				},
			},
			suggestion = {
				debounce = 75,
				throttle = 75,
			},
		})
		local keymap = vim.keymap.set

		keymap("n", "<leader>ac", "<Esc><Cmd>AvanteChat<CR>", { desc = "Avante Chat" })
		keymap("v", "<leader>ae", "<Esc><Cmd>AvanteEdit<CR>", { desc = "Avante Edit" })
		keymap("n", "<leader>at", "<Esc><Cmd>AvanteToggle<CR>", { desc = "Avante Toggle" })
		-- keymap("n", "<M-5>", "<Esc><Cmd>AvanteToggle<CR>", { desc = "Avante Toggle" })
		keymap("n", "<M-5>", function()
			panes_util.toggle_pane({
				pane_open_predicate = {
					-- TODO: Because `Avante` window is on the bottom "left" of the screen
					--       It will always be hit first in the loop, causing `win` parameter below to be that
					--       Need to find a way to make it (1) selectable which win will be there from this list
					--       or (2) sends array of wins instead just one win
					filetype = { "AvanteSelectedFiles", "Avante", "AvanteInput" },
				},
				on_pane_is_being_focused = function(win)
					vim.cmd("AvanteToggle")
				end,
				on_pane_existed = function(win)
					vim.api.nvim_set_current_win(win.winid)
				end,
				on_pane_not_existed = function()
					vim.cmd("AvanteToggle")
				end,
			})
		end, { desc = "Avante Toggle" })
		keymap("n", "<leader>aa", "<Esc><Cmd>AvanteAsk<CR>", { desc = "Avante Ask" })
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
		"hrsh7th/nvim-cmp",
		"nvim-telescope/telescope.nvim",
		"zbirenbaum/copilot.lua",
		"MeanderingProgrammer/render-markdown.nvim",
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
