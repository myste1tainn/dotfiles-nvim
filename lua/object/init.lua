local qf = require("object.quickfix")
local dg = require("object.diagnostics")

local M = {}
M.setup = function()
	qf.setup({
		on_open = function()
			-- When quickfix is opened, close diagnostics
			dg.close()
		end,
	})
	dg.setup({
		on_open = function()
			-- When diagnostics is opened, close quickfix
			qf.close()
		end,
	})
end
return M
