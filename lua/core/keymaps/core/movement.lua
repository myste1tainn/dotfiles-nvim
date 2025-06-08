local keymap_util = require("utils.keymap")

return function(bufnr)
	-- Refactored using keymap_util.map_for_all_and_terminal
	keymap_util.map_for_all_and_terminal("<M-h>", "<C-w>h", { desc = "Move to left split" })
	keymap_util.map_for_all_and_terminal("<M-l>", "<C-w>l", { desc = "Move to right split" })
	keymap_util.map_for_all_and_terminal("<M-j>", "<C-w>j", { desc = "Move to below split" })
	keymap_util.map_for_all_and_terminal("<M-k>", "<C-w>k", { desc = "Move to above split" })
	keymap_util.map_for_all_and_terminal("<M-t>", "<Cmd>tabnew<CR>", { desc = "New tab", silent = true })
	keymap_util.map_for_all_and_terminal("<M-[>", "<Cmd>tabprevious<CR>", { desc = "Next tab", silent = true })
	keymap_util.map_for_all_and_terminal("<M-]>", "<Cmd>tabnext<CR>", { desc = "Previous tab", silent = true })
end
