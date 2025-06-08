return {
	"mg979/vim-visual-multi",
	config = function() end,
	init = function()
		vim.schedule(function()
			pcall(require, "vim-visual-multi")
		end)
	end,
}
