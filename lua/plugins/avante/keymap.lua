local keymap = vim.keymap.set

keymap("n", "<leader>ac", ":AvanteChat<CR>", { desc = "Avante Chat" })
keymap("v", "<leader>ae", ":AvanteEdit<CR>", { desc = "Avante Edit" })
keymap("n", "<leader>at", ":AvanteToggle<CR>", { desc = "Avante Toggle" })
keymap("n", "<leader>aa", ":AvanteAsk<CR>", { desc = "Avante Ask" })
