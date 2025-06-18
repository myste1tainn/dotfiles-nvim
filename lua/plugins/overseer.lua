-- Setup for overseer.nvim
return {
	{
		"stevearc/overseer.nvim",
		config = function()
			require("overseer").setup()
			local prebuilt_templates = require("user.overseer.templates")
			for _, template in pairs(prebuilt_templates) do
				require("overseer").register_template(template)
			end
		end,
	},
}
