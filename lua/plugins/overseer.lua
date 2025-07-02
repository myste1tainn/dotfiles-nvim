-- Setup for overseer.nvim
return {
	{
		"stevearc/overseer.nvim",
		lazy = false,
		config = function()
			-- refer to this https://github.com/stevearc/overseer.nvim/blob/master/doc/reference.md#parameters
			local overseer = require("overseer")
			overseer.setup({
				default_strategy = "jobstart",
				template_timeout = 5000, -- Timeout for template loading
				task_list = {
					bindings = {
						["<C-q>"] = "Close",
						["<C-c>"] = false,
					},
				},
			})
			-- -- Register once at start-up
			-- overseer.register_component("tail_quickfix", function(params)
			-- 	-- merge user params with our defaults
			-- 	params = vim.tbl_extend("force", {
			-- 		tail = true, -- stream incrementally
			-- 		items_only = true, -- ignore non-matching lines
			-- 	}, params or {})
			--
			-- 	-- reuse the stock quickfix component
			-- 	local base = require("overseer.component.on_output_quickfix").constructor(params)
			--
			-- 	-- kill the expensive full-buffer rebuild
			-- 	base.on_pre_result = function() end
			-- 	return base
			-- end)
			local prebuilt_templates = require("user.overseer.templates")

			for _, template in pairs(prebuilt_templates) do
				overseer.register_template(template)
			end
		end,
	},
}
