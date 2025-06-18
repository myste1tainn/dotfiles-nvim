local M = {}

local function get_indent(line)
	return vim.fn.indent(line)
end

local function jump_to_first_char(lnum)
	local col = vim.fn.matchstr(vim.fn.getline(lnum), [[^\s*]]):len()
	vim.api.nvim_win_set_cursor(0, { lnum, col })
end

function M.jump_indent_inward()
	local cur_line = vim.fn.line(".")
	local cur_indent = get_indent(cur_line)
	for lnum = cur_line + 1, vim.fn.line("$") do
		if get_indent(lnum) > cur_indent then
			jump_to_first_char(lnum)
			return
		end
	end
end

function M.jump_indent_outward()
	local cur_line = vim.fn.line(".")
	local cur_indent = get_indent(cur_line)
	for lnum = cur_line - 1, 1, -1 do
		if get_indent(lnum) < cur_indent then
			jump_to_first_char(lnum)
			return
		end
	end
end

local function is_blank(line)
	return vim.fn.getline(line):match("^%s*$") ~= nil
end

function M.jump_next_sibling()
	local cur_line = vim.fn.line(".")
	local cur_indent = get_indent(cur_line)
	local last_line = vim.fn.line("$")

	-- Skip current sibling region
	local lnum = cur_line + 1
	while lnum <= last_line and get_indent(lnum) == cur_indent and not is_blank(lnum) do
		lnum = lnum + 1
	end

	-- Find next sibling region
	while lnum <= last_line do
		if get_indent(lnum) == cur_indent and not is_blank(lnum) then
			jump_to_first_char(lnum)
			return
		end
		lnum = lnum + 1
	end
end

function M.jump_prev_sibling()
	local cur_line = vim.fn.line(".")
	local cur_indent = get_indent(cur_line)

	-- Skip current sibling region
	local lnum = cur_line - 1
	while lnum >= 1 and get_indent(lnum) == cur_indent and not is_blank(lnum) do
		lnum = lnum - 1
	end

	-- Find previous sibling region
	while lnum >= 1 do
		if get_indent(lnum) == cur_indent and not is_blank(lnum) then
			-- Rewind to the first line of that region
			local start = lnum
			while start > 1 and get_indent(start - 1) == cur_indent and not is_blank(start - 1) do
				start = start - 1
			end
			jump_to_first_char(start)
			return
		end
		lnum = lnum - 1
	end
end

return M
