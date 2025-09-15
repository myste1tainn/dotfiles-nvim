-- 1. bootstrap lazy.nvim (tiny, no config side-effects)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- 2. declare ONLY the bits Avante needs
require("lazy").setup({
	{ -- Avante itself
		"yetone/avante.nvim",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			"stevearc/dressing.nvim",
			"nvim-telescope/telescope.nvim", -- for selector provider
			{
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
			},
		},
		build = "make", -- Avante’s treesitter grammar
		config = function()
			require("avante").setup({
				provider = "copilot",
				-- provider = "openai",
				auto_suggestions_provider = "copilot",
				-- auto_suggestions_provider = "openai",
				api_key = os.getenv("OPENAI_API_KEY"),
				providers = {
					openai = {
						-- model = "gpt-4o-mini",
						-- model = "gpt-4o",
						model = "gpt-4.1",
					},
				},
				dual_boost = {
					enabled = true,
					first_provider = "openai",
					second_provider = "copilot",
					prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
					timeout = 60000, -- Timeout in milliseconds
				},
				behaviour = {
					auto_suggestions = false, -- Experimental stage
					auto_set_highlight_group = true,
					auto_set_keymaps = true,
					auto_apply_diff_after_generation = false,
					support_paste_from_clipboard = true,
					minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
					enable_token_counting = true, -- Whether to enable token counting. Default to true.
				},
				windows = {
					-- position = "bottom",
					position = "right",
					-- position = "smart",
					-- input = {
					-- 	width = 60,
					-- },
				},
				selector = {
					provider = "telescope",
				},
				-- input = {
				-- 	provider = "snacks", -- snacks.nvim input provider}
				-- },
				mappings = {
					suggestion = {
						accept = "<M-l>",
						next = "<M-.>",
						prev = "<M-,>",
						dismiss = "<M-e>",
					},
				},
				suggestion = {
					debounce = 75,
					throttle = 75,
				},
			})
			vim.keymap.set("n", "<M-5>", "<cmd>AvanteToggle<cr>", { desc = "Avante: Open Avante window" })
		end,
	},
}, { ui = { icons = false } })
