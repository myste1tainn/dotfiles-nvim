local base_ctor = require("overseer.component.on_output_quickfix").constructor

local M = {}

function M.constructor(params)
	-- TODO: Update this qf.tail component to process the output in background, so it doesn't block the UI
	params = vim.tbl_extend("force", {
		tail = true, -- stream incrementally
		items_only = true, -- ignore lines that don't match efm
	}, params or {})

	local base = base_ctor(params)
	base.on_pre_result = function() end -- disable the heavy final parse
	return base
end

return M
