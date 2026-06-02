return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"L3MON4D3/LuaSnip",
		"zbirenbaum/copilot-cmp", -- Copilot integration
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-path",
		"MeanderingProgrammer/render-markdown.nvim", -- Markdown rendering support
		{
			"petertriho/cmp-git",
			event = "VeryLazy",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-telescope/telescope.nvim",
			},
			config = function() end,
		}, -- Git integration for completion
	},
	config = function()
		-- TODO: This probably linked to the correct cmp module, but wrong file within
		-- which then causes `cmp.setu` line to later have diagnostic hint
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		require("cmp_git").setup({
			filetypes = { "gitcommit", "gitrebase" },
		})

		local common_mapping = require("plugins-config.nvim-cmp.mappings").common(cmp, luasnip)

		vim.opt.completeopt = "menu,menuone,preinsert,preview"
		---@diagnostic disable-next-line: redundant-parameter
		cmp.setup({
			preselect = cmp.PreselectMode.Item, -- Preselect the first item in the completion menu
			completeopt = "menu,menuone,preinsert,preview",
			completion = {
				completeopt = "menu,menuone,preinsert,preview",
			},
			sorting = {
				priority_weight = 2, -- bigger number ↔ later comparators hurt less
				comparators = require("plugins-config.nvim-cmp.comparators"),
			},
			snippet = {
				-- REQUIRED - you must specify a snippet engine
				expand = function(args)
					-- vim.fn['vsnip#anonymous'](args.body) -- For `vsnip` users.
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
					-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
					-- vim.fn['UltiSnips#Anon'](args.body) -- For `ultisnips` users.
				end,
			},
			mapping = vim.tbl_deep_extend("force", {}, common_mapping),
			formatting = {
				format = function(entry, vim_item)
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						luasnip = "[Snip]",
						buffer = "[Buf]",
						path = "[Path]",
					})[entry.source.name]
					return vim_item
				end,
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "copilot" },
				{ name = "buffer" },
				{ name = "path" },
				-- { name = "vsnip" }, -- For vsnip users.
				{ name = "luasnip" }, -- For luasnip users.
				-- { name = 'ultisnips' }, -- For ultisnips users.
				-- { name = 'snippy' }, -- For snippy users.
				{ name = "render-markdown" }, -- For markdown rendering
			}, {
				-- { name = "buffer" },
			}),
		})

		-- Set configuration for specific filetype.
		cmp.setup.filetype({ "gitcommit", "gitrebase" }, {
			sources = cmp.config.sources({
				{ name = "git" },
			}, {
				{ name = "buffer" },
			}),
		})

		-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(common_mapping),
			sources = {
				{ name = "buffer" },
			},
		})

		-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline(":", {
			preselect = cmp.PreselectMode.Item,
			mapping = cmp.mapping.preset.cmdline(common_mapping),
			completeopt = "menu,menuone,preinsert,preview",
			completion = {
				completeopt = "menu,menuone,preinsert,preview",
			},
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})
	end,
}
