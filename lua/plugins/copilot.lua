return {
	"zbirenbaum/copilot.lua",
	event = "InsertEnter", -- Load when entering insert mode
	-- NOTE: This is depended on by the nvim-cmp plugin, so no need to add cmp as a dependency here.
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true, -- this enables ghost text suggestions
				auto_trigger = true, -- automatically show suggestions while typing
				debounce = 75,
				keymap = {
					-- accept = "<M-l>", -- or "<C-l>", "<M-]>",
					-- <M-l> was my original key, but then I found out that <C-e> is end-of-line in terminol mode
					-- And I now I used that to accept zsh-suggestions, the copilot suggestion UX/UI seems the same,
					-- So to retain the same UX/UI, I use <C-e> to accept copilot suggestions
					-- But then again, this key is conflicting with the default "cancel" key in nvim-cmp, so I need to configure that too
					accept = false,
					next = "<M-.>",
					prev = "<M-,>",
					dismiss = "<M-e>",
				},
			},
		})

		-- 2. Our own smarter <C-e> mapping
		local map_opts = { expr = true, silent = true, noremap = true, replace_keycodes = false }

		vim.keymap.set("i", "<C-e>", function()
			local suggestion = require("copilot.suggestion")

			if suggestion and suggestion.is_visible() then
				-- accept() already feeds the keys itself,
				-- so just call it and return an empty string for the mapping
				suggestion.accept()
				return ""
			end

			-- fallback: behave like the normal <C-e> (end of line)
			return vim.api.nvim_replace_termcodes("<C-e>", true, false, true)
		end, map_opts)
		-- local cmp = require("cmp")
		-- -- Add your configuration here
		-- cmp.event:on("menu_opened", function()
		-- 	vim.b.copilot_suggestion_hidden = true
		-- end)
		--
		-- cmp.event:on("menu_closed", function()
		-- 	vim.b.copilot_suggestion_hidden = false
		-- end)
	end,
}
-- return {}
