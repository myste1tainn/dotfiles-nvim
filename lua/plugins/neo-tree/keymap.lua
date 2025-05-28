local keymap = vim.keymap.set

keymap("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle File Tree", silent = true })
keymap("n", "<leader>o", ":Neotree reveal<CR>", { desc = "Reveal in File Tree", silent = true })
