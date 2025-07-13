local wins = require("utils.wins")

---@class PaneOpenPredicate Predication for checking if a pane is open, either buftype, filetype, or customtype must be set
---@field buftype (string[]|string|function)? If set as string, buftype will be used to check if the pane is open, focused, or closed., as function that function should be returning string
---@field filetype (string[]|string|function)? If set as string, filetype will be used to check if the pane is open, focused, or closed., as function that function should be returning string
---@field customtype (function)? A function that should return boolean, if true then the pane is considered open

---@class TogglePaneOpts
---@field pane_open_predicate PaneOpenPredicate
---@field on_pane_existed function? If not provided, default is to set the current window to the pane that is already open
---@field on_pane_not_existed function Called when the pane is not open, should open the pane
---@field on_pane_is_being_focused function Called when the pane is being focused, should handle the logic for focusing the pane, if you want toggle behavior then you can close the pane here
---

local function validate_pane_open_predicate(predicate)
	if not predicate or type(predicate) ~= "table" then
		error("pane_open_predicate must be a table")
	end
	local buf_file_type_check = function(value)
		return value and type(value) ~= "string" and type(value) ~= "table" and type(value) ~= "function"
	end
	if buf_file_type_check(predicate.buftype) then
		error("pane_open_predicate.buftype must be a string or a table of strings or a function")
	end
	if buf_file_type_check(predicate.filetype) then
		error("pane_open_predicate.filetype must be a string or a table of strings or a function")
	end
	if predicate.customtype and type(predicate.customtype) ~= "function" then
		error("pane_open_predicate.customtype must be a function")
	end
end

local function validate_toggel_pane_opts(opts)
	if not opts or type(opts) ~= "table" then
		error("opts must be a table")
	end
	if not opts.pane_open_predicate or type(opts.pane_open_predicate) ~= "table" then
		error("opts.pane_open_predicate must be a table")
	end
	validate_pane_open_predicate(opts.pane_open_predicate)
end

local function is_pane_open(win, predicate)
	local bufnr = vim.api.nvim_win_get_buf(win.winid)
	local buf = vim.bo[bufnr]
	-- Get buf from winid
	local validates = function(key, value)
		if value then
			if buf[key] and type(value) == "string" then
				if buf[key] == value then
					return true
				end
			end
			if type(value) == "table" then
				for _, v in ipairs(value) do
					if buf[key] == v then
						return true
					end
				end
			end
		end
	end
	if validates("buftype", predicate.buftype) then
		return true
	end
	if validates("filetype", predicate.filetype) then
		return true
	end
	if predicate.customtype and predicate.customtype(win) then
		return true
	end
	return false
end

local M = {}

---Find windows that match the condition
---@param predicate (fun(win: vim.fn.getwininfo.ret.item): boolean)|string Provide as string to find win by filetype, or function to custom predicate
---@return vim.fn.getwininfo.ret.item|nil
function M.find_win(predicate)
	if type(predicate) == "string" then
		local expected_filetype = predicate
		predicate = function(win)
			local bufnr = vim.api.nvim_win_get_buf(win.winid)
			local buf = vim.bo[bufnr]
			return buf.filetype == expected_filetype
		end
	end

	for _, win in ipairs(vim.fn.getwininfo()) do
		if predicate(win) then
			return win
		end
	end
	return nil
end

---Focus windows that match the condition
---@param predicate (fun(win: vim.fn.getwininfo.ret.item): boolean)|string Provide as string to find win by filetype, or function to custom predicate
function M.focus_win(predicate)
	local win = M.find_win(predicate)
	if win then
		if vim.api.nvim_get_current_win() ~= win.winid then
			vim.api.nvim_set_current_win(win.winid)
		end
	else
		vim.notify("No window found matching the predicate", vim.log.levels.WARN)
	end
end

---Close windows that match the condition
---@param predicate (fun(win: vim.fn.getwininfo.ret.item): boolean)|string Provide as string to find win by filetype, or function to custom predicate
function M.close_win(predicate)
	local win = M.find_win(predicate)
	if win then
		vim.api.nvim_win_close(win.winid, true)
	else
		vim.notify("No window found matching the predicate", vim.log.levels.WARN)
	end
end

---Toggle panes with specified options
---@param opts TogglePaneOpts
function M.toggle_pane(opts)
	validate_toggel_pane_opts(opts)
	local pane_open = false
	for _, win in ipairs(vim.fn.getwininfo()) do
		if is_pane_open(win, opts.pane_open_predicate) then
			pane_open = true
			if win.tabnr == vim.fn.tabpagenr() then
				if vim.api.nvim_get_current_win() == win.winid then
					opts.on_pane_is_being_focused(win)
				else
					if opts.on_pane_existed then
						opts.on_pane_existed(win)
					else
						vim.api.nvim_set_current_win(win.winid)
					end
				end
				return
			end
		end
	end
	if not pane_open then
		opts.on_pane_not_existed()
	end
end

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

function M.open_current_buffer_in_float()
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

function M.is_main_editor_window(win)
	if vim.api.nvim_win_get_config(win).relative ~= "" then
		return false -- it's a floating window
	end

	local buf = vim.api.nvim_win_get_buf(win)
	local ft = vim.bo[buf].filetype
	local bt = vim.bo[buf].buftype

	for _, excluded in ipairs(wins.special_wins) do
		if ft == excluded then
			return false
		end
	end

	for _, excluded in ipairs(wins.excluded_buftypes) do
		if bt == excluded then
			return false
		end
	end

	return true
end

-- Find the first "main" window
function M.find_main_editor_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if M.is_main_editor_window(win) then
			return win
		end
	end
	return nil
end

return M
