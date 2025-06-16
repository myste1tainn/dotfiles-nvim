local keymap_util = require("utils.keymap")

return function(bufnr)
	keymap_util.map_for_all_and_terminal("<M-0>", "<Cmd>NoiceAll<CR>", { desc = "Open NoiceAll", silent = true })
	keymap_util.map_for_all_and_terminal(
		"<M-1>",
		"<Cmd>Neotree toggle<CR>",
		{ desc = "Toggle file explorer (neotree)", silent = true }
	)

	local function get_all_buf_options(bufnr)
		local opts = {}
		for _, opt in ipairs(vim.api.nvim_get_all_options_info()) do
			local name = opt
			local ok, val = pcall(vim.api.nvim_buf_get_option, bufnr, name)
			if ok then
				opts[name] = val
			end
		end
		return opts
	end

	local function get_win_options(winid)
		local opts = {}
		for k, _ in pairs(vim.wo) do
			local ok, val = pcall(vim.api.nvim_win_get_option, winid, k)
			if ok then
				opts[k] = val
			end
		end
		return opts
	end

	local open_current_buffer_in_float = function()
		local buf = vim.api.nvim_get_current_buf()
		local buf_options = get_all_buf_options(buf)
		local win_options = get_win_options(vim.api.nvim_get_current_win())
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
		for option, value in pairs(win_options) do
			vim.api.nvim_win_set_option(win, option, value)
		end
		for option, value in pairs(buf_options) do
			vim.api.nvim_buf_set_option(buf, option, value)
		end
	end

	keymap_util.map_for_all_and_terminal(
		"<M-f>",
		open_current_buffer_in_float,
		{ desc = "Open Buffer in Floating Window", silent = true }
	)
end
