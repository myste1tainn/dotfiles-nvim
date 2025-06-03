local toggle_aerial = function()
	-- Exit insert or terminal mode first
	if vim.fn.mode() == "i" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	end
	if vim.fn.mode() == "t" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
	end

	-- get current win objects in the current tab
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_win_get_buf(current_win)
	-- if the current win is an aerial window, close it
	if vim.api.nvim_buf_get_option(current_buf, "filetype") == "aerial" then
		vim.cmd("AerialClose")
		return
	end

	-- if the current win is not an aerial window, check if there is an aerial window in the current tab
	local aerial_win = nil
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.tabnr == vim.fn.tabpagenr() then
			-- if the window does not belong to the current tab, skip it
			goto continue
		end
		if win.filetype == "aerial" then
			aerial_win = win.winid
		end
		::continue::
	end

	if aerial_win then
		-- if there is an aerial window, focus it
		vim.api.nvim_set_current_win(aerial_win)
	else
		vim.cmd("AerialOpen")
	end
end

return {
	"stevearc/aerial.nvim",
	opts = {},
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function(_, opts)
		require("aerial").setup({
			-- optionally use on_attach to set keymaps when aerial has attached to a buffer
			on_attach = function(bufnr)
				-- Jump forwards/backwards with '{' and '}'
				vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
				vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
			end,
			-- Highlight the symbol in the source buffer when cursor is in the aerial win
			highlight_on_hover = true,

			-- When jumping to a symbol, highlight the line for this many ms.
			-- Set to false to disable
			highlight_on_jump = 300,

			-- Jump to symbol in source window when the cursor moves
			autojump = true,
		})
		-- You probably also want to set a keymap to toggle aerial
		vim.keymap.set({ "n", "v", "i", "t" }, "<M-2>", toggle_aerial, { desc = "Toggle Aerial" })
		vim.keymap.set("t", "<M-2>", toggle_aerial, { desc = "Toggle Aerial" })

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "aerial",
			callback = function()
				vim.opt_local.wrap = true
				vim.opt_local.linebreak = true -- Optional: Prevents wrapping in the middle of words
			end,
		})
	end,
}
