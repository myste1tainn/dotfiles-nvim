local util_wins = require("utils.wins")
local tabs = require("user.autocommands.tabs")

-- Returns true if a tabpage with the given handle exists
local function tab_exists(tabnr)
	for _, id in ipairs(vim.api.nvim_list_tabpages()) do
		if id == tabnr then
			return true
		end
	end
	return false
end

-- Close every buffer except the one you’re on -------------------------------
-- -----------------------------------------------------------
--  BufOnly   - close every *file* buffer except the one
--             you are looking at, while keeping special
--             UI buffers (Neogit, qf, help, Telescope …)
-----------------------------------------------------------
vim.api.nvim_create_user_command("BufOnly", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		-- skip the buffer you’re on
		if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
			local bt = vim.api.nvim_get_option_value("buftype", { buf = buf }) -- '' for “normal” files
			local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })

			-- delete only real *file* buffers that aren’t on the keep-list
			if bt == "" and not util_wins.keep_filetypes[ft] then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
	end
end, { desc = "Close every file buffer except the current one" })

-- Purge [No Name] buffers that have never been modified ---------------------
vim.api.nvim_create_user_command("BufPurgeNoName", function()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf) == "" and not vim.api.nvim_buf_get_option(buf, "modified") then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end, { desc = "Delete unnamed & unmodified buffers" })

-- :TabBack  ➜  jump to that tab (if it still exists) ───────────────────────
vim.api.nvim_create_user_command("TabLastVisited", function()
	if tabs.last_visited_tab and tabs.last_visited_tab ~= vim.fn.tabpagenr() then
		-- if last tab exsts, go to it
		if tab_exists(tabs.last_visited_tab) == 1 then
			vim.cmd("tabnext " .. tabs.last_visited_tab)
		else
			print("" .. tabs.last_visited_tab .. " does not exist")
			vim.cmd("tabprevious")
		end
	end
end, { desc = "Go to previously visited tab" })
