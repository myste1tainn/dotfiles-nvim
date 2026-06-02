local keymap = vim.keymap.set
local markdown_fns = require("user.markdown.functions")
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "Avante" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.textwidth = 0
		vim.opt_local.formatoptions:append("t")
	end,
})

return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "Avante" },
	config = function()
		require("render-markdown").setup({
			file_types = { "markdown", "Avante" },
		})

		vim.keymap.set("v", "<leader>cb", function()
			markdown_fns.toggle_checkbox_visual()
		end, { desc = "Toggle checkbox", silent = true })

		vim.keymap.set("v", "<leader>cl", function()
			markdown_fns.toggle_list_visual()
		end, { desc = "Toggle list bullet", silent = true })

		vim.keymap.set("v", "<leader>ct", function()
			markdown_fns.cycle_list_type_visual()
		end, { desc = "Cycle list type", silent = true })

		-- vim.keymap.set("v", "<Tab>", function()
		-- 	markdown_fns.indent_list_visual()
		-- end, { desc = "Indent list item", silent = true })

		-- vim.keymap.set("v", "<S-Tab>", function()
		-- 	markdown_fns.unindent_list_visual()
		-- end, { desc = "Unindent list item", silent = true })
	end,
	dependencies = {
		-- {
		-- 	"gaoDean/autolist.nvim",
		-- 	ft = {
		-- 		"markdown",
		-- 		"text",
		-- 		"tex",
		-- 		"plaintex",
		-- 		"norg",
		-- 	},
		-- 	config = function()
		-- 	  local autolist = require("autolist")
		-- 		autolist.setup()
		--
		-- 		keymap("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", { desc = "Autolist New Bullet", silent = true })
		-- 		keymap("n", "o", "o<cmd>AutolistNewBullet<cr>", { desc = "Autolist New Bullet", silent = true })
		-- 		keymap(
		-- 			"n",
		-- 			"O",
		-- 			"O<cmd>AutolistNewBulletBefore<cr>",
		-- 			{ desc = "Autolist New Bullet Before", silent = true }
		-- 		)
		-- 		keymap(
		-- 			"n",
		-- 			"<CR>",
		-- 			"<cmd>AutolistToggleCheckbox<cr><CR>",
		-- 			{ desc = "Autolist Toggle Checkbox", silent = true }
		-- 		)
		-- 		-- TODO: Check if you need this function, if so find a keymap for it
		-- 		-- keymap("n", "<C-r>", "<cmd>AutolistRecalculate<cr>", { desc = "Autolist Recalculate", silent = true })
		--
		-- 		-- cycle list types with dot-repeat
		-- 		keymap(
		-- 			"n",
		-- 			"<leader>cn",
		-- 			autolist.cycle_next_dr,
		-- 			{ desc = "Autolist Cycle Next", expr = true, silent = true }
		-- 		)
		-- 		keymap(
		-- 			"n",
		-- 			"<leader>cp",
		-- 			autolist.cycle_prev_dr,
		-- 			{ desc = "Autolist Cycle Previous", expr = true, silent = true }
		-- 		)
		--
		-- 		-- if you don't want dot-repeat
		-- 		-- keymap("n", "<leader>cn", "<cmd>AutolistCycleNext<cr>")
		-- 		-- keymap("n", "<leader>cp", "<cmd>AutolistCycleNext<cr>")
		--
		-- 		-- functions to recalculate list on edit
		-- 		keymap(
		-- 			"n",
		-- 			">>",
		-- 			">><cmd>AutolistRecalculate<cr>",
		-- 			{ desc = "Autolist Recalculate Forward", silent = true }
		-- 		)
		-- 		keymap(
		-- 			"n",
		-- 			"<<",
		-- 			"<<<cmd>AutolistRecalculate<cr>",
		-- 			{ desc = "Autolist Recalculate Backward", silent = true }
		-- 		)
		-- 		keymap(
		-- 			"n",
		-- 			"dd",
		-- 			"dd<cmd>AutolistRecalculate<cr>",
		-- 			{ desc = "Autolist Recalculate Delete", silent = true }
		-- 		)
		-- 		keymap(
		-- 			"v",
		-- 			"d",
		-- 			"d<cmd>AutolistRecalculate<cr>",
		-- 			{ desc = "Autolist Recalculate Visual Delete", silent = true }
		-- 		)
		-- 	end,
		-- },
	},
}
