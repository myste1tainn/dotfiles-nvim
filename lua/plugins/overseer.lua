-- Setup for overseer.nvim
return {
	{
		"stevearc/overseer.nvim",
		lazy = false,
		config = function()
			-- refer to this https://github.com/stevearc/overseer.nvim/blob/master/doc/reference.md#parameters
			require("overseer").setup({
				task_list = {
					bindings = {
						["<C-q>"] = "Close",
						["<C-c>"] = false,
					},
				},
			})
			local prebuilt_templates = require("user.overseer.templates")
			for _, template in pairs(prebuilt_templates) do
				require("overseer").register_template(template)
			end
		end,
	},
}
