local keymap_util = require("utils.keymap")

return function(bufnr)
	keymap_util.map_for_all_and_terminal("<M-0>", "<Cmd>messages<CR>", { desc = "Open Messages", silent = true })
	keymap_util.map_for_all_and_terminal(
		"<M-1>",
		"<Cmd>Neotree toggle<CR>",
		{ desc = "Toggle file explorer (neotree)", silent = true }
	)

	local open_current_buffer_in_float = function()
		local buf = vim.api.nvim_get_current_buf()
		local width = math.floor(vim.o.columns * 0.9)
		local height = math.floor(vim.o.lines * 0.9)
		local row = math.floor((vim.o.lines - height) / 2)
		local col = math.floor((vim.o.columns - width) / 2)
		local win = vim.api.nvim_open_win(buf, true, {
			relative = "editor",
			width = width,
			height = height,
			row = row,
			col = col,
			style = "minimal",
			border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
		})
		vim.api.nvimwin_set_option(win, "number", true)
		vim.api.nvim_win_set_option(win, "relativenumber", true)
		vim.api.nvim_buf_set_option(buf, "modifiable", true)
	end

	keymap_util.map_for_all_and_terminal(
		"<M-f>",
		open_current_buffer_in_float,
		{ desc = "Open Buffer in Floating Window", silent = true }
	)
end
