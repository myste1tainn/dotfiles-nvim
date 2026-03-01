local function feedkeys_to_buf(bufnr, keys)
	local cur_win = vim.api.nvim_get_current_win()

	-- find a window showing the buffer
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			vim.api.nvim_set_current_win(win)
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
			vim.api.nvim_set_current_win(cur_win)
			return true
		end
	end

	return false
end

local function flutter_hot_reload()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({ recent_first = true })

	for _, task in ipairs(tasks) do
		if task.name == "flutter run" and task:is_running() then
			vim.fn.chansend(task.strategy.job_id, "r\n")
			vim.notify("Flutter hot reload sent!", vim.log.levels.INFO)
			return
		end
	end
end

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.dart" },
	callback = flutter_hot_reload,
})
