local trouble = require("trouble")

local M = {
	length = 0,
	current_index = 0,
	buf_length = 0,
	buf_current_index = 0,
	on_open = function() end,
	on_close = function() end,
}

M.setup = function(opts)
	opts = opts or {}
	if opts.on_open then
		M.on_open = opts.on_open
	end
	if opts.on_close then
		M.on_close = opts.on_close
	end
end

M.update = function()
	local all = vim.diagnostic.get()
	M.length = #all
	if M.length == 0 then
		M.current_index = 0
	else
		M.current_index = 1
	end

	local buf = vim.api.nvim_get_current_buf()
	local buf_diags = vim.diagnostic.get(buf)
	M.buf_length = #buf_diags
	if M.buf_length == 0 then
		M.buf_current_index = 0
	else
		M.buf_current_index = 1
	end
end

-- Returns true if we should proceed, false if we should abort
local function navigate(direction, buf_only)
	assert(direction == "next" or direction == "prev", "direction must be 'next' or 'prev'")

	if buf_only then
		if M.buf_length == 0 then
			vim.notify("No diagnostics for the active buffer", vim.log.levels.INFO)
			return false
		end

		-- Detect wrap-around before moving
		if direction == "next" and M.buf_current_index >= M.buf_length then
			vim.notify("Last item for active buffer reached, continuing from top", vim.log.levels.INFO)
		elseif direction == "prev" and M.buf_current_index <= 1 then
			vim.notify("First item for active buffer reached, continuing from bottom", vim.log.levels.INFO)
		end

		vim.cmd("Trouble diagnostics " .. direction .. " filter.buf=0")
		vim.cmd("Trouble diagnostics jump filter.buf=0")

		-- Update buf index
		if direction == "next" then
			M.buf_current_index = (M.buf_current_index % M.buf_length) + 1
		else
			M.buf_current_index = ((M.buf_current_index - 2 + M.buf_length) % M.buf_length) + 1
		end
	else
		if M.length == 0 then
			vim.notify("No diagnostics found", vim.log.levels.INFO)
			return false
		end

		if direction == "next" and M.current_index >= M.length then
			vim.notify("Last item reached, continuing from top", vim.log.levels.INFO)
		elseif direction == "prev" and M.current_index <= 1 then
			vim.notify("First item reached, continuing from bottom", vim.log.levels.INFO)
		end

		vim.cmd("Trouble diagnostics " .. direction)
		vim.cmd("Trouble diagnostics jump")

		if direction == "next" then
			M.current_index = (M.current_index % M.length) + 1
		else
			M.current_index = ((M.current_index - 2 + M.length) % M.length) + 1
		end
	end

	return true
end

M.next = function(opts)
	opts = opts or {}
	local buf_only = opts.buf_only or false

	local ok = navigate("next", buf_only)
	if not ok then
		return
	end

	if not M.is_open() then
		M.on_open()
	end
end

M.prev = function(opts)
	opts = opts or {}
	local buf_only = opts.buf_only or false

	local ok = navigate("prev", buf_only)
	if not ok then
		return
	end

	if not M.is_open() then
		M.on_open()
	end
end

M.open = function(opts)
	opts = opts or {}
	opts.mode = "diagnostics"
	trouble.open(opts)
	M.on_open()
end

M.close = function()
	trouble.close("diagnostics")
	M.on_close()
end

M.is_empty = function()
	return M.length == 0
end

M.win_and_buf = function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local buf_ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if buf_ft == "trouble" then
			local mode = vim.b[buf].trouble_mode
			if mode == "diagnostics" then
				return win, buf
			end
		end
	end
	return nil
end

M.is_open = function()
	return M.win_and_buf() ~= nil
end

vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, { callback = M.update })

return M
