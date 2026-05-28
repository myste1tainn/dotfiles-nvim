local keymap = vim.keymap.set

return function(bufnr)
	-- Launching FzfLua
	-- keymap("n", "<leader>f", "<Cmd>FzfLua<CR>", { desc = "Launch FzfLua", silent = true })
	-- keymap("n", "<leader>ff", "<Cmd>FzfLua files<CR>", { desc = "Launch FzfLua files", silent = true })
	-- keymap("n", "<leader>fl", "<Cmd>FzfLua live_grep<CR>", { desc = "Launch FzfLua live_grep", silent = true })
	-- keymap("n", "<leader>fb", "<Cmd>FzfLua buffers<CR>", { desc = "Launch FzfLua buffers", silent = true })
	-- keymap("n", "<leader>fg", "<Cmd>FzfLua git_files<CR>", { desc = "Launch FzfLua git_files", silent = true })
	-- keymap("n", "<leader>fd", "<Cmd>FzfLua git_diff<CR>", { desc = "Launch FzfLua git_diff", silent = true })

	-- Same as above but using Telescope
	keymap("n", "<leader>f", "<Cmd>Telescope<CR>", { desc = "Launch Telescope", silent = true })
	keymap("n", "<leader>ff", "<Cmd>Telescope find_files<CR>", { desc = "Launch Telescope find_files", silent = true })
	keymap("n", "<leader>fl", "<Cmd>Telescope live_grep<CR>", { desc = "Launch Telescope live_grep", silent = true })
	-- keymap("n", "<leader>fw", function()
	-- 	require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
	-- end, { desc = "Grep current word under cursor", silent = true })
	keymap("n", "<leader>fb", "<Cmd>Telescope buffers<CR>", { desc = "Launch Telescope buffers", silent = true })
	keymap("n", "<leader>fgg", "<Cmd>Telescope git_files<CR>", { desc = "Launch Telescope git_files", silent = true })
	keymap(
		"n",
		"<leader>fgc",
		"<Cmd>Telescope git_commits<CR>",
		{ desc = "Launch Telescope git_commits", silent = true }
	)
	keymap(
		"n",
		"<leader>fgb",
		"<Cmd>Telescope git_bcommits<CR>",
		{ desc = "Launch Telescope git_bcommits", silent = true }
	)
	keymap("n", "<leader>fd", "<Cmd>Telescope git_status<CR>", { desc = "Launch Telescope git_status", silent = true })
	keymap("n", "<leader>fh", "<Cmd>Telescope help_tags<CR>", { desc = "Launch Telescope help_tags", silent = true })
	keymap("n", "<leader>fc", "<Cmd>Telescope commands<CR>", { desc = "Launch Telescope commands", silent = true })
	keymap(
		"n",
		"<leader>fC",
		"<Cmd>Telescope command_history<CR>",
		{ desc = "Launch Telescope command_history", silent = true }
	)

	keymap("n", "<leader>fd", function() require("fzf-lua").lsp_document_symbols() end, { desc = "Launch Fzf lsp_document_symbols", silent = true })
	-- keymap(
	-- 	"n",
	-- 	"<leader>fw",
	-- 	vim.lsp.buf.workspace_symbol,
	-- 	{ desc = "Launch Fzf lsp_workspace_symbols", silent = true }
	-- )
end
