local trouble = require("trouble")

-- Object that represents quickfix and allows interaction with it
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

function M.update()
	M.length = vim.fn.len(vim.fn.getqflist())
	M.current_index = vim.fn.getqflist({ idx = 0 }).idx
end

local safe_cmd = function(cmd)
	local ok, err = pcall(vim.cmd, cmd)
	if not ok and err then
		vim.notify("Error executing command '" .. cmd .. "': " .. err, vim.log.levels.DEBUG)
	end
end

local function with_post_move(fn)
	return function(...)
		fn(...)
		M.update()
		if not M.is_open() and M.length > 0 then
			M.open()
		end
	end
end

function M.next()
	with_post_move(function()
		if M.current_index >= M.length then
			vim.notify("No more quickfix items. Continuing from the top.", vim.log.levels.INFO)
			safe_cmd("cfirst")
		else
			safe_cmd("cnext")
		end
	end)()
end

function M.prev()
	with_post_move(function()
		if M.current_index <= 1 then
			vim.notify("No previous quickfix items. Continuing from the bottom.", vim.log.levels.INFO)
			safe_cmd("clast")
		else
			safe_cmd("cprevious")
		end
	end)()
end

function M.is_open()
	return M.win_and_buf() ~= nil
end

function M.win_and_buf()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local buf_ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if buf_ft == "trouble" then
			local view = require("trouble.view").get({ win })
			if view and view[1] and view[1].mode == "quickfix" then
				return win, buf
			end
		end
	end
	return nil
end

function M.open(opts)
	opts = opts or {}
	vim.cmd("Trouble quickfix")
	if opts.focus then
		local qf_win, _ = M.win_and_buf()
		if qf_win then
			vim.api.nvim_set_current_win(qf_win)
		end
	end
	M.on_open()
end

function M.close()
	trouble.close("quickfix")
	M.on_close()
end

function M.is_empty()
	return M.length == 0
end

-- MARK: - Internal listeners
-- Every time the quickfix list is changed, it updates its internal state
vim.api.nvim_create_autocmd("QuickFixCmdPost", { pattern = "*", callback = M.update })

-- Force anyone other plugins who try to open the quickfix window to use Trouble instead
local function cabbr(lhs, rhs)
	local cmd = ("cnoreabbrev <expr> %s (getcmdtype()==':' && getcmdline()==#'%s') ? '%s' : '%s'"):format(
		lhs,
		lhs,
		rhs,
		lhs
	)
	-- print("running cmd:", cmd)
	vim.cmd(cmd)
end

cabbr("copen", "Trouble quickfix")
cabbr("cope", "Trouble quickfix")
cabbr("cwindow", "Trouble quickfix")
cabbr("cw", "Trouble quickfix")

local function open_trouble()
	-- Only open when there are items
	if vim.fn.getqflist({ size = 0 }).size > 0 then
		-- local current = vim.api.nvim_get_current_win()
		M.open()

		-- return cursor if the current win opened and focused this way becomes quickfix or trouble
		-- for _, win in ipairs(vim.api.nvim_list_wins()) do
		-- 	local buf = vim.api.nvim_win_get_buf(win)
		-- 	if
		-- 		vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix"
		-- 		or vim.api.nvim_buf_get_option(buf, "filetype") == "trouble"
		-- 	then
		-- 		-- Return to where you were
		-- 		vim.api.nvim_set_current_win(current)
		-- 		break
		-- 	end
		-- end
	end
end

-- 1. Any time a quick-fix window actually opens (no matter who opened it)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf", -- fires for real quick-fix buffers
	callback = function()
		-- run *after* the window finishes opening to avoid closing the buffer we’re in
		vim.schedule(function()
			vim.cmd("cclose") -- close the native qf
			open_trouble() -- show Trouble instead
		end)
	end,
})

-- 2. When a command *only* populates the list (grep, make, etc.) but doesn’t open it
-- vim.api.nvim_create_autocmd("QuickFixCmdPost", {
-- 	pattern = "*",
-- 	callback = function()
-- 		vim.defer_fn(function() -- let the command finish first
-- 			open_trouble()
-- 		end, 20) -- 20 ms guard handles async pop-ups
-- 	end,
-- })

return M
