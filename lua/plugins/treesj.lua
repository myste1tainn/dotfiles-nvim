return {
	"Wansmer/treesj",
	dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
	config = function()
		require("treesj").setup({
			use_default_keymaps = false,
			max_join_length = 999999,
		})
		vim.keymap.set("n", "<leader>j", require("treesj").join)
		vim.keymap.set("n", "<leader>s", require("treesj").split)
		vim.keymap.set("n", "<leader>m", require("treesj").toggle)
		vim.keymap.set("n", "<leader>J", function()
			require("treesj").join({ recursive = true })
		end)
		vim.keymap.set("n", "<leader>S", function()
			require("treesj").split({ recursive = true })
		end)
		vim.keymap.set("n", "<leader>M", function()
			require("treesj").toggle({ split = { recursive = true }, join = { recursive = true } })
		end)
	end,
}
