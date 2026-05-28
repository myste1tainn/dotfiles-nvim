local keymap = vim.keymap.set

return function(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Peek definition using lspsaga
	-- keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
	keymap("n", "gdp", "<cmd>Lspsaga peek_definition<CR>", opts)
	keymap("n", "gdd", "<cmd>Lspsaga goto_definition<CR>", opts)
	keymap("n", "gdt", "<cmd>Lspsaga goto_type_definition<CR>", opts)
	-- Hover using lspsaga
	keymap("n", "H", "<cmd>Lspsaga hover_doc<CR>", opts)
	keymap("i", "<C-/>", "<cmd>Lspsaga hover_doc<CR>", opts)
	-- Show signature help using lspsaga
	-- keymap("n", "<C-k>", "<cmd>Lspsaga signature_help<CR>", opts) -- There's no such thing as signature_help in lspsaga, check if there's something similar
	-- Rename using lspsaga
	keymap("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
	-- Code actions using lspsaga
	keymap({ "n", "v" }, "<M-CR>", "<cmd>Lspsaga code_action<CR>", opts)
	-- Show references using lspsaga
	-- keymap("n", "gr", "<cmd>Lspsaga finder<CR>", opts)
	local lspsaga_finder = function()
		require("lspsaga.finder").lsp_finder({
			layout = "float",
			finder_action_keys = {
				open = { "o", "<CR>" },
				vsplit = "v",
				split = "s",
				tabe = "t",
				quit = { "q", "<ESC>" },
				scroll_down = "<C-f>",
				scroll_up = "<C-b>",
			},
		})
	end
	keymap("n", "grr", "<cmd>Lspsaga finder<cr>", opts)
	keymap("n", "gri", "<cmd>Lspsaga finder<cr>", opts)

	-- Show line diagnostics
	keymap("n", "<M-d>", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
end
