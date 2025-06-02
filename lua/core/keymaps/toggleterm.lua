local keymap = vim.keymap.set

return function(bufnr)
	local opts = { buffer = 0 }
	keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit Terminal" })
	-- NOTE: Do not use <C-[> here, because in terminal sometimes you'll have to use <C-[> to escape from a prompt or a command, and it will conflict with the terminal exit mapping.
	-- keymap("t", "<C-[>", [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit Terminal" })
	-- NOTE: The <C-\\> mapping is defined it the pluign itself because otherwise it won't work with other fucntionalities of nvim
	-- i.e. 3<C-\\> will not work if we define it here
	keymap("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
	keymap("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
	keymap("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
	keymap("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
	keymap("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end
