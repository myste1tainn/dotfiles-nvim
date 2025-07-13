return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"zbirenbaum/copilot-cmp", -- Copilot integration
		{ "hrsh7th/cmp-cmdline", lazy = false },
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
		local cmp = require("cmp")
		local compare = cmp.config.compare -- helper that exposes all built-ins
		local luasnip = require("luasnip")

		require("cmp_git").setup({
			filetypes = { "gitcommit", "gitrebase" },
		})

		cmp.setup({
			preselect = cmp.PreselectMode.None, -- Preselect the first item in the completion menu
			completion = {
				completeopt = "menu,menuone,preview",
			},
			sorting = {
				priority_weight = 2, -- bigger number ↔ later comparators hurt less
				comparators = {
					compare.offset, -- start-of-word matches win
					compare.exact, -- exact prefix wins
					compare.score, -- LSP / source fuzzy score
					compare.recently_used, -- what you confirmed before
					compare.locality, -- identifiers closer to the cursor
					compare.kind, -- functions > variables > snippets … (optional)
					compare.sort_text, -- fallback to server-provided sortText
					compare.length, -- shorter names win if still tied
					compare.order, -- final deterministic tie-break
				},
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
			mapping = {
				["<Tab>"] = cmp.mapping.confirm({ select = true }),
				["<C-n>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s", "c" }),
				["<C-p>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s", "c" }),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),

				-- Accept Copilot suggestion even when cmp menu is open
				-- ["<M-l>"] = cmp.mapping(function(fallback)
				["<C-e>"] = cmp.mapping(function(fallback)
					local copilot = require("copilot.suggestion")
					if copilot.is_visible() then
						copilot.accept()
					elseif cmp.visible() then
						cmp.close()
					else
						fallback()
					end
				end, { "i", "s", "c" }),
				["<C-[>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.close()
					else
						fallback()
					end
				end, { "i", "s", "c" }),
			},
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
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline(":", {
			preselect = cmp.PreselectMode.None,
			mapping = cmp.mapping.preset.cmdline({
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			}),
			completion = {
				completeopt = "menu,menuone,preview",
			},
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
		})
	end,
}
