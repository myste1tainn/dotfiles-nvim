local neotest = require("neotest")
local M = {}

function M.open()
	-- Open the Neotest output panel and summary
	neotest.output_panel.open()
	neotest.summary.open()
	-- Focus a window with filetype=neotest-output-panel
	local output_bufnr = vim.fn.bufnr("neotest-output-panel")
	if output_bufnr ~= -1 then
		vim.api.nvim_set_current_buf(output_bufnr)
	end
end

return M
