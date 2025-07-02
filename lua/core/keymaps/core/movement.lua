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

	keymap({ "i", "c", "s" }, "<C-a>", function()
		local mode = vim.api.nvim_get_mode().mode
		-- If insert mode, exit first_provider
		if mode == "i" then
			vim.cmd("stopinsert")
			-- Then move to the beginning of the line
			vim.cmd("normal! ^")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>^", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<Home>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>^", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Move to beginning of line" })

	-- This move to the end of the line, but without removing the selection
	-- keymap({ "i", "c", "s" }, "<C-e>", "<C-o>$", { desc = "Move to end of line" })
	keymap({ "i", "c", "s" }, "<C-e>", function()
		local mode = vim.api.nvim_get_mode().mode
		-- If insert mode, exit first
		if mode == "i" then
			vim.cmd("stopinsert")
			-- Then move to the end of the lines
			vim.cmd("normal! $")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>A", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<End>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>$", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Move to end of line" })

	keymap({ "i", "c", "s" }, "<C-b>", function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "i" then
			vim.cmd("stopinsert")
			vim.cmd("normal! h")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>h", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<Left>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>h", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Move back one character" })

	keymap({ "i", "c", "s" }, "<C-f>", function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "i" then
			vim.cmd("stopinsert")
			vim.cmd("normal! l")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>l", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<Right>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>l", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Move forward one character" })

	keymap({ "i", "c", "s" }, "<M-b>", function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "i" then
			vim.cmd("stopinsert")
			vim.cmd("normal! b")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>b", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<C-Left>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>b", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Move back one word" })

	keymap({ "i", "c", "s" }, "<M-f>", function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "i" then
			vim.cmd("stopinsert")
			vim.cmd("normal! w")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>w", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<C-Right>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>w", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Move forward one word" })

	keymap({ "i", "c", "s" }, "<C-d>", function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "i" then
			vim.cmd("stopinsert")
			vim.cmd("normal! l")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>x", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<Del>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>x", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Delete character under cursor" })

	keymap({ "i", "c", "s" }, "<C-h>", "<BS>", { desc = "Delete character before cursor" })

	keymap({ "i", "c", "s" }, "<M-d>", function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "i" then
			vim.cmd("stopinsert")
			vim.cmd("normal! dw")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>dw", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<C-Del>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>dw", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Delete word after cursor" })

	keymap({ "i", "c", "s" }, "<M-BS>", function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "i" then
			vim.cmd("stopinsert")
			vim.cmd("normal! db")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>db", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<C-Backspace>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>db", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Delete word before cursor" })

	keymap({ "i", "c", "s" }, "<C-k>", function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "i" then
			vim.cmd("stopinsert")
			vim.cmd("normal! d$")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>d$", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local right = vim.fn.strlen(vim.fn.getcmdline()) - vim.fn.getcmdpos() + 1
			local del = vim.api.nvim_replace_termcodes("<Del>", true, false, true)
			vim.fn.feedkeys(string.rep(del, right), "n")
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>d$", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Kill from cursor to end of line" })

	keymap({ "i", "c", "s" }, "<C-u>", function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "i" then
			vim.cmd("stopinsert")
			vim.cmd("normal! d0")
			vim.cmd("startinsert")
		elseif mode == "S" or mode == "s" then
			local keys = vim.api.nvim_replace_termcodes("<Esc>d0", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		elseif mode == "c" then
			local keys = vim.api.nvim_replace_termcodes("<C-u>", true, false, true)
			vim.api.nvim_feedkeys(keys, "n", false)
		else
			vim.api.nvim_feedkeys(
				vim.api.nvim_replace_termcodes("<C-o>d0", true, false, true),
				"n", -- non-recursive
				false -- do not remap
			)
		end
	end, { desc = "Kill from cursor to beginning of line" })

	-- NOTE: Vim already have this behavior
	-- keymap("i", "<C-w>", "<C-o>db", { desc = "Kill from cursor to previous word" })

	keymap("n", "]i", movment_indent.jump_indent_inward, { desc = "Jump to child (more indented)" })
	keymap("n", "[i", movment_indent.jump_indent_outward, { desc = "Jump to parent (less indented)" })
	keymap("n", "]I", movment_indent.jump_next_sibling, { desc = "Jump to next sibling (same indent)" })
	keymap("n", "[I", movment_indent.jump_prev_sibling, { desc = "Jump to previous sibling (same indent)" })
end
