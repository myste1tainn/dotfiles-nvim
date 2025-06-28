return {
	"mg979/vim-visual-multi",
	lazy = true,
	init = function()
		vim.api.nvim_create_autocmd("UIEnter", {
			once = true,
			callback = function()
				vim.defer_fn(function()
					require("lazy").load({ plugins = { "vim-visual-multi" } })
				end, 200)
			end,
		})
	end,
}
