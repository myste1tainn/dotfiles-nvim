return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"zbirenbaum/copilot-cmp", -- Copilot integration
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-path",
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		cmp.setup({
			preselect = cmp.PreselectMode.Item, -- Preselect the first item in the completion menu
			completion = {
				completeopt = "menu,menuone,noinsert,preview",
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
				["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
				["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if luasnip.jumpable(-1) then
						luasnip.jump(-1)
					elseif cmp.visible() then
						cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
					else
						fallback()
					end
				end, { "i", "s" }),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.close(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),

				-- Accept Copilot suggestion even when cmp menu is open
				["<M-l>"] = cmp.mapping(function(fallback)
					local copilot = require("copilot.suggestion")
					if copilot.is_visible() then
						copilot.accept()
					else
						fallback()
					end
				end, { "i", "s" }),
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
			}, {
				-- { name = "buffer" },
			}),
		})

		-- Set configuration for specific filetype.
		cmp.setup.filetype("gitcommit", {
			sources = cmp.config.sources({
				{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
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
			mapping = cmp.mapping.preset.cmdline({
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			}),
			preselect = cmp.PreselectMode.Item,
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
