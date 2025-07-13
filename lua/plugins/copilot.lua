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

		-- TODO: Tried this "fallback" mapping, but it doesn't work as expected, keymap.get is nil-ed
		-- -- 2. Our own smarter <C-e> mapping
		-- -- Capture whatever was mapped *before* we override it
		-- local prior = vim.keymap.get("i", "<C-e>")[1] -- nil if nothing
		--
		-- vim.keymap.set("i", "<C-e>", function()
		-- 	local copilot = require("copilot.suggestion")
		-- 	if copilot and copilot.is_visible() then
		-- 		copilot.accept()
		-- 		return
		-- 	end
		--
		-- 	-- If there was a previous mapping, replay it
		-- 	if prior then
		-- 		if prior.callback then -- it was a Lua callback
		-- 			prior.callback()
		-- 		elseif prior.rhs then -- it was a Vim string mapping
		-- 			vim.api.nvim_feedkeys(prior.rhs, "n", false)
		-- 		end
		-- 	else
		-- 		-- No prior mapping: fall back to builtin behaviour
		-- 		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<End>", true, false, true), "n", false)
		-- 	end
		-- end, { noremap = true, desc = "Copilot accept or delegate to previous <C-e>" })
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

			return vim.api.nvim_replace_termcodes("<End>", true, false, true)
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
