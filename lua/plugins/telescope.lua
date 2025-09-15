return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
	},
	config = function()
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		require("telescope").setup({
			defaults = {
				file_ignore_patterns = { ".git/", "node_modules/", "%.lock" },
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden", -- add this line
				},
			},
			pickers = {
				find_files = {
					hidden = true,
				},
				git_commits = {
					attach_mappings = function(_, map)
						map("i", "<C-y>", function(prompt_bufnr)
							local entry = require("telescope.actions.state").get_selected_entry()
							local hash = entry.value
							vim.fn.setreg("+", hash) -- to system clipboard
							vim.fn.setreg('"', hash) -- to unnamed register
							print("Yanked commit hash: " .. hash)
						end)
						map("i", "<C-o>", function(prompt_bufnr)
							local entry = require("telescope.actions.state").get_selected_entry()
							local commit = entry.value
							require("telescope.actions").close(prompt_bufnr)
							require("telescope._extensions.git_commit_files").git_files_at_commit(commit)
						end)
						return true
					end,
				},
				git_bcommits = {
					attach_mappings = function(_, map)
						map("i", "<C-y>", function(prompt_bufnr)
							local entry = require("telescope.actions.state").get_selected_entry()
							local hash = entry.value
							vim.fn.setreg("+", hash)
							vim.fn.setreg('"', hash)
							print("Yanked commit hash: " .. hash)
						end)
						map("i", "<C-o>", function(prompt_bufnr)
							local entry = action_state.get_selected_entry()
							local commit = entry.value
							local filepath = vim.fn.expand("%")
							actions.close(prompt_bufnr)
							local cmd = string.format("Gedit %s:%s", commit, filepath)
							vim.cmd(cmd)
						end)
						return true
					end,
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
				},
			},
		})

		require("telescope").load_extension("fzf")
		require("telescope").load_extension("ui-select")
		require("telescope").load_extension("file_browser")
		require("telescope").load_extension("git_commit_files")
	end,
}
