local keymap_util = require("utils.keymap")
local keymap = vim.keymap.set
local movment_indent = require("user.movement.indent")

return function(bufnr)
	-- Refactored using keymap_util.map_for_all_and_terminal
	keymap_util.map_for_all_and_terminal("<M-h>", "<C-w>h", { desc = "Move to left split" })
	keymap_util.map_for_all_and_terminal("<M-l>", "<C-w>l", { desc = "Move to right split" })
	keymap_util.map_for_all_and_terminal("<M-j>", "<C-w>j", { desc = "Move to below split" })
	keymap_util.map_for_all_and_terminal("<M-k>", "<C-w>k", { desc = "Move to above split" })
	keymap_util.map_for_all_and_terminal("<M-t>", "<Cmd>tabnew<CR>", { desc = "New tab", silent = true })
	-- TODO: This clashes with exit insert / terminal mode, so it is commented out for now, find a better solution
	-- keymap_util.map_for_all_and_terminal([[<C-[>]], "<Cmd>tabprevious<CR>", { desc = "Next tab", silent = true })
	-- keymap_util.map_for_all_and_terminal([[<C-]>]], "<Cmd>tabnext<CR>", { desc = "Previous tab", silent = true })
	-- TODO: Make a key map / unset a key map that clashes with the terminal mode i.e. <M-f> that you set for showing float window, in terminal
	--       <C-a> is supposed to be moving to the beginning of the line, <C-d> is Delete, <M-d> is Delete word, <C-e> is End of line
	keymap_util.map_for_all_and_terminal(
		"<M-[>",
		"<Cmd>BufferLineCyclePrev<CR>",
		{ desc = "BufferLine: Next tab", silent = true }
	)
	keymap_util.map_for_all_and_terminal(
		"<M-]>",
		"<Cmd>BufferLineCycleNext<CR>",
		{ desc = "BufferLine: Previous tab", silent = true }
	)

	keymap("t", "<C-p>", "<Up>", { desc = "Movement Up for Terminal" })
	keymap("t", "<C-n>", "<Down>", { desc = "Movement Down for Terminal" })

	-- Key mappings for insert mode, inspired by terminal-like behavior
	keymap({ "i", "c", "s" }, "<C-p>", "<Up>", { desc = "Movement Up for Terminal" })
	keymap({ "i", "c", "s" }, "<C-n>", "<Down>", { desc = "Movement Down for Terminal" })
	keymap({ "i", "c", "s" }, "<C-a>", "<C-o>^", { desc = "Move to beginning of line" })
	keymap({ "i", "c", "s" }, "<C-e>", "<C-o>$", { desc = "Move to end of line" })
	keymap({ "i", "c", "s" }, "<C-b>", "<C-o>b", { desc = "Move back one character" })
	keymap({ "i", "c", "s" }, "<C-f>", "<C-o>w", { desc = "Move forward one character" })
	keymap({ "i", "c", "s" }, "<M-b>", "<C-o>b", { desc = "Move back one word" })
	keymap({ "i", "c", "s" }, "<M-f>", "<C-o>w", { desc = "Move forward one word" })
	keymap({ "i", "c", "s" }, "<C-d>", "<C-o>x", { desc = "Delete character under cursor" })
	keymap({ "i", "c", "s" }, "<C-h>", "<BS>", { desc = "Delete character before cursor" })
	keymap({ "i", "c", "s" }, "<M-d>", "<C-o>daw", { desc = "Delete word after cursor" })
	keymap({ "i", "c", "s" }, "<M-BS>", "<C-o>db", { desc = "Delete word before cursor" })
	keymap({ "i", "c", "s" }, "<C-k>", "<C-o>D", { desc = "Kill from cursor to end of line" })
	keymap({ "i", "c", "s" }, "<C-u>", "<C-o>d0", { desc = "Kill from cursor to beginning of line" })
	-- NOTE: Vim already have this behavior
	-- keymap("i", "<C-w>", "<C-o>db", { desc = "Kill from cursor to previous word" })

	keymap("n", "]i", movment_indent.jump_indent_inward, { desc = "Jump to child (more indented)" })
	keymap("n", "[i", movment_indent.jump_indent_outward, { desc = "Jump to parent (less indented)" })
	keymap("n", "]I", movment_indent.jump_next_sibling, { desc = "Jump to next sibling (same indent)" })
	keymap("n", "[I", movment_indent.jump_prev_sibling, { desc = "Jump to previous sibling (same indent)" })
end
