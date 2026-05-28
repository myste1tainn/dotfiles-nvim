-- Setup for nvim-treesitter
-- NOTE: This is setup for nvim-treesitter, and nvim-treesitter-textobjects on the master (not main) branch
-- return {
-- 	{
-- 		"nvim-treesitter/nvim-treesitter",
-- 		run = ":TSUpdate",
-- 		config = function()
-- 			---@diagnostic disable-next-line: missing-fields
-- 			require("nvim-treesitter.configs").setup({
-- 				ensure_installed = { "go", "python", "dart", "lua", "javascript", "rust", "starlark" },
-- 				highlight = {
-- 					enable = true,
-- 				},
-- 				indent = {
-- 					enable = true,
-- 					disable = { "dart" },
-- 				},
-- 				textobjects = {
-- 					select = {
-- 						enable = true,
-- 						lookahead = true,
-- 						keymaps = {
-- 							["af"] = "@function.outer",
-- 							["if"] = "@function.inner",
-- 							["ai"] = "@conditional.outer",
-- 							["ii"] = "@conditional.inner",
-- 							["ae"] = "@else.outer",
-- 							["ie"] = "@else.inner",
-- 						},
-- 					},
-- 				},
-- 			})
-- 		end,
-- 		dependencies = {
-- 			"nvim-treesitter/nvim-treesitter-textobjects",
-- 		},
-- 	},
-- }
local languages = {
	"go",
	"gomod",
	"gotmpl",
	"python",
	"dart",
	"lua",
	"javascript",
	"typescript",
	"rust",
	"starlark",
	"json",
	"yaml",
	"toml",
	"html",
	"css",
	"sql",
}

-- Filetype detection for PlantUML
vim.filetype.add({
	extension = {
		puml = "plantuml",
		plantuml = "plantuml",
		pu = "plantuml",
		iuml = "plantuml",
		wsd = "plantuml",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"go.sum",
		"go.mod",
		"gotmpl",
		unpack(languages),
	},
	callback = function()
		vim.treesitter.start()
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		-- branch = "main",
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")
			ts.setup({
				-- Directory to install parsers and queries to
				install_dir = vim.fn.stdpath("data") .. "/site",
				indent = {
					enable = true,
				},
			})
			ts.install(languages)
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
			config = function()
				local tst = require("nvim-treesitter-textobjects")
				tst.setup({
					select = {
						-- Automatically jump forward to textobj, similar to targets.vim
						lookahead = true,
						-- You can choose the select mode (default is charwise 'v')
						--
						-- Can also be a function which gets passed a table with the keys
						-- * query_string: eg '@function.inner'
						-- * method: eg 'v' or 'o'
						-- and should return the mode ('v', 'V', or '<c-v>') or a table
						-- mapping query_strings to modes.
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@function.outer"] = "V", -- linewise
							["@class.outer"] = "<c-v>", -- blockwise
						},
						-- If you set this to `true` (default is `false`) then any textobject is
						-- extended to include preceding or succeeding whitespace. Succeeding
						-- whitespace has priority in order to act similarly to eg the built-in
						-- `ap`.
						--
						-- Can also be a function which gets passed a table with the keys
						-- * query_string: eg '@function.inner'
						-- * selection_mode: eg 'v'
						-- and should return true of false
						include_surrounding_whitespace = false,
					},
				})

				local tsts = require("nvim-treesitter-textobjects.select")
				vim.keymap.set({ "x", "o" }, "af", function()
					tsts.select_textobject("@function.outer", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "if", function()
					tsts.select_textobject("@function.inner", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ai", function()
					tsts.select_textobject("@conditional.outer", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ii", function()
					tsts.select_textobject("@conditional.inner", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ae", function()
					tsts.select_textobject("@else.outer", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ie", function()
					tsts.select_textobject("@else.inner", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ac", function()
					tsts.select_textobject("@class.outer", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "ic", function()
					tsts.select_textobject("@class.inner", "textobjects")
				end)
				vim.keymap.set({ "x", "o" }, "as", function()
					tsts.select_textobject("@local.scope", "locals")
				end)
			end,
		},
	},
}
