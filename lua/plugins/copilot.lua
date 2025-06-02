return {
	"zbirenbaum/copilot.lua",
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true, -- this enables ghost text suggestions
				auto_trigger = true, -- automatically show suggestions while typing
				debounce = 75,
				keymap = {
					accept = "<M-l>", -- or "<C-l>", "<M-]>",
					next = "<M-,>",
					prev = "<M-.>",
					dismiss = "<M-e>",
				},
			},
		})
		local cmp = require("cmp")
		-- Add your configuration here
		cmp.event:on("menu_opened", function()
			vim.b.copilot_suggestion_hidden = true
		end)

		cmp.event:on("menu_closed", function()
			vim.b.copilot_suggestion_hidden = false
		end)
	end,
}
-- return {}
