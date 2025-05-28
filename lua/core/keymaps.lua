local keymap = vim.keymap.set

-- Set CursorHold delay to 100ms
vim.o.updatetime = 100

-- Standard LSP keymaps
local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Peek definition using lspsaga
	keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
	-- Hover using lspsaga
	keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
	-- Go to implementation
	keymap("n", "gi", vim.lsp.buf.implementation, opts)
	-- Show signature help using lspsaga
	keymap("n", "<C-k>", "<cmd>Lspsaga signature_help<CR>", opts)
	-- Rename using lspsaga
	keymap("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
	-- Code actions using lspsaga
	keymap("n", "<M-CR>", "<cmd>Lspsaga code_action<CR>", opts)
	-- Show references using lspsaga
	keymap("n", "gr", "<cmd>Lspsaga finder<CR>", opts)
	-- Format
	keymap("n", "<leader>f", function()
		vim.lsp.buf.format({ async = true })
	end, opts)

	-- Additional lspsaga keymaps
	-- Diagnostic jump
	keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
	keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
	-- Show line diagnostics
	keymap("n", "<leader>e", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
end

-- Attach LSP keymaps when LSP client is attached
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		lsp_keymaps(args.buf)

		-- Show diagnostics on CursorHold
		--vim.api.nvim_create_autocmd("CursorHold", {
		--	buffer = args.buf,
		--	callback = function()
		--		vim.cmd("Lspsaga show_cursor_diagnostics")
		--	end,
		--})
		vim.api.nvim_create_autocmd("CursorMoved", {
			callback = function()
				vim.diagnostic.open_float(nil, {
					focusable = false,
					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
					border = "rounded",
					source = "always",
					prefix = " ",
					scope = "cursor",
				})
			end,
		})
	end,
})
