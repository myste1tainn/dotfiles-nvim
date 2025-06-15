local keymap_util = require("utils.keymap")

return function(bufnr)
	-- Quit buffer, Save & Quit, Quit All, Save all & Quit
	keymap_util.map_for_all_and_terminal("<C-q>", "<Cmd>q<CR>", { desc = "Quit Buffer", silent = true })
	keymap_util.map_for_all_and_terminal("<C-x>", "<Cmd>bd<CR>", { desc = "Delete Buffer", silent = true })
	keymap_util.map_for_all_and_terminal("<C-a><C-q>", "<Cmd>qa<CR>", { desc = "Quit All", silent = true })
	keymap_util.map_for_all_and_terminal("<C-a><C-s>", "<Cmd>wa<CR>", { desc = "Save All", silent = true })
	keymap_util.map_for_all_and_terminal("<C-a><C-x>", "<Cmd>wqa<CR>", { desc = "Save All & Quit", silent = true })
	keymap_util.map_for_all_and_terminal("<C-s>", "<Cmd>wa<CR>", { desc = "Save", silent = true })

	-- TODO: Find a way to distinguish between buffer types, and then some of them should be using  "bd" for closing rather than "q" i.e. the Editor buffer should use "bd", but the float buffer should use "q"
end
