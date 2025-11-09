local trouble = require("trouble")

-- Object repersents diagnostics and allows interaction with it
local M = {
	length = 0,
	current_index = 0,
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
	local diagnostics = vim.diagnostic.get()
	M.length = #diagnostics
	if M.length == 0 then
		M.current_index = 0
	else
		-- Assuming diagnostics are sorted by severity or position
		M.current_index = 1
	end
end

M.next = function()
	vim.cmd("Trouble diagnostics next")
	vim.cmd("Trouble diagnostics jump")
	M.update()
	if not M.is_open() then
		-- NOTE: If it's not opened then next function will opened it
		-- so we need to call on_open manually
		M.on_open()
	end
end

M.prev = function()
	vim.cmd("Trouble diagnostics prev")
	vim.cmd("Trouble diagnostics jump")
	M.update()
	if not M.is_open() then
		-- NOTE: If it's not opened then next function will opened it
		-- so we need to call on_open manually
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

-- MARK: - Internal listeners
-- Every time the diagnostics are changed, it updates its internal state
vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, { callback = M.update })

return M
