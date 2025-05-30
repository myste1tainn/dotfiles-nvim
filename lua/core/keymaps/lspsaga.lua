local keymap = vim.keymap.set

return function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Peek definition using lspsaga
	keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
	-- Hover using lspsaga
	keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
	-- Show signature help using lspsaga
	keymap("n", "<C-k>", "<cmd>Lspsaga signature_help<CR>", opts)
	-- Rename using lspsaga
	keymap("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
	-- Code actions using lspsaga
	keymap("n", "<M-CR>", "<cmd>Lspsaga code_action<CR>", opts)
	-- Show references using lspsaga
	keymap("n", "gr", "<cmd>Lspsaga finder<CR>", opts)

	-- Additional lspsaga keymaps
	-- Diagnostic jump
	keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
	keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
	-- Show line diagnostics
	keymap("n", "<leader>e", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
end
