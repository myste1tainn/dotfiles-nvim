-- NOTE: Problem is that some how the latest avante.nvim, when it tries to set win width / height
-- It set too much for the Avante area that is squashed AvanteInput to 1 width / height
-- This script is a workaround to resize the AvanteInput window all the time
vim.api.nvim_create_autocmd("FileType", {
	pattern = "AvanteInput",
	callback = function(args)
		local bufnr = args.buf
		local winid = vim.fn.bufwinid(bufnr)
		if winid == -1 then
			return
		end

		local min_width, max_width = 80, 80
		local min_height, max_height = 10, 20

		local function resize()
			if not vim.api.nvim_win_is_valid(winid) then
				return false
			end
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return false
			end

			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local width = min_width
			local height = math.max(#lines, min_height)

			for _, line in ipairs(lines) do
				width = math.max(width, #line)
			end

			width = math.min(math.max(width, min_width), max_width)
			height = math.min(height, max_height)

			vim.api.nvim_win_set_width(winid, width)
			vim.api.nvim_win_set_height(winid, height)

			return true
		end

		-- Initial resize
		vim.schedule(resize)

		-- Timer loop to keep resizing as window lives
		local timer = vim.loop.new_timer()
		local closing = false
		timer:start(
			0,
			50,
			vim.schedule_wrap(function()
				if not resize() and not closing then
					closing = true
					timer:stop()
					timer:close()
				end
			end)
		)
	end,
})
