return {
	"Wansmer/treesj",
	dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
	config = function()
		require("treesj").setup({ use_default_keymaps = false })
		vim.keymap.set("n", "K", require("treesj").split) -- split block
		-- NOTE: Just J will conflict with the default join behavior in Vim.
		-- But if you find that gJ works the same way, then might make sense to override it.
		vim.keymap.set("n", "gJ", require("treesj").join) -- keep gJ for joining
	end,
}
