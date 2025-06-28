return {
	"sindrets/winshift.nvim",
	event = "VeryLazy",
	cmd = "WinShift",
	init = function()
		vim.keymap.set("n", "<C-w><C-m>", function()
			-- NOTE: If this doesn't work then try vim.cmd("WinShift")
			require("winshift").start()
		end, { desc = "WinShift: Start moving windows" })
	end,
	config = function()
		require("winshift").setup()
	end,
}
