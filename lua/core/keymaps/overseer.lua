local keymap = vim.keymap.set

return function(bufnr)
	-- Overseer uses
	keymap({ "n", "v", "i" }, "<leader>r", "<Esc>:OverseerRun<CR>", { desc = "Run Overseer Task" })
	-- ª = <M-9>
	keymap({ "n", "v", "i" }, "<M-9>", "<Esc>:OverseerToggle<CR>", { desc = "Toggle Overseer" })
end
