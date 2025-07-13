return {
	"sindrets/winshift.nvim",
	event = "VeryLazy",
	cmd = "WinShift",
	init = function()
		vim.keymap.set("n", "<C-w><C-m>", function()
			vim.cmd("WinShift")
		end, { desc = "WinShift: Start moving windows" })
	end,
	config = function()
		require("winshift").setup()
	end,
}
