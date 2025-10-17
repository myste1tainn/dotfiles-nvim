local keymap = vim.keymap.set
local keymap_util = require("utils.keymap")
local buf_actions = require("user.actions.buffers")

return function(bufnr)
	keymap_util.map_for_all_and_terminal([[<M-t>]], "<Cmd>tabnew<CR>", { desc = "New tab", silent = true })
	-- TODO: This clashes with exit insert / terminal mode, so it is commented out for now, find a better solution
	keymap_util.map_for_all_and_terminal([[<M-{>]], "<Cmd>tabprevious<CR>", { desc = "Next tab", silent = true })
	keymap_util.map_for_all_and_terminal([[<M-}>]], "<Cmd>tabnext<CR>", { desc = "Previous tab", silent = true })
	keymap("n", "zz", "<Cmd>TabLastVisited<CR>", { desc = "Toggle last visited buffer", silent = true })
	vim.keymap.set("n", "<leader>b", function()
		vim.ui.select(vim.tbl_keys(buf_actions), {
			prompt = "Buffer actions",
		}, function(choice)
			if choice then
				buf_actions[choice]()
			end
		end)
	end, { desc = "Pick a buffer action" })
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
end
