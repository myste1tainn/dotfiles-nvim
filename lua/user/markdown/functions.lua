local M = {}

local function visual_line_range()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	return start_line, end_line
end

local function do_for_each_line(fn)
	local start_line, end_line = visual_line_range()
	for line = start_line, end_line do
		vim.api.nvim_win_set_cursor(0, { line, 0 })
		fn()
	end
end

function M.toggle_checkbox_visual()
	do_for_each_line(function()
		vim.cmd("AutolistToggleCheckbox")
	end)
end

function M.toggle_list_visual()
	do_for_each_line(function()
		vim.cmd("AutolistToggleList")
	end)
end

function M.cycle_list_type_visual()
	do_for_each_line(function()
		vim.cmd("AutolistCycleListType")
	end)
end

function M.indent_list_visual()
	do_for_each_line(function()
		vim.cmd("AutolistTab")
	end)
end

function M.unindent_list_visual()
	do_for_each_line(function()
		vim.cmd("AutolistShiftTab")
	end)
end

return M
