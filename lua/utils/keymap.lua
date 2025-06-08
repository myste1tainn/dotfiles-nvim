local keymap = vim.keymap.set
local M = {}

function M.map_for_all_and_terminal(keys, fn_or_cmd, opts)
	local fn1, fn2 = nil, nil
	if type(fn_or_cmd) == "function" then
		fn1 = function()
			-- Exit insert or terminal mode first
			if vim.fn.mode() == "i" then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
			end
			if vim.fn.mode() == "t" then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", true)
			end
			fn_or_cmd()
		end
		fn2 = fn1
	else
		fn1 = "<Esc>" .. fn_or_cmd
		fn2 = "<C-\\><C-n>" .. fn_or_cmd
	end
	keymap({ "n", "v", "i" }, keys, fn1, opts)
	keymap({ "t" }, keys, fn2, opts)
end

return M
