-- Indentation basics
vim.opt.expandtab = true -- use spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.smartindent = true -- simple smart C-like indent

-- Make sure filetype-based indents are on
vim.cmd("filetype plugin indent on")

-- Avoid surprises
vim.opt.paste = false -- paste mode disables autoindent

-- local original_set_width = vim.api.nvim_win_set_width
--
-- vim.api.nvim_win_set_width = function(winid, width)
-- 	local ok, buf = pcall(vim.api.nvim_win_get_buf, winid)
-- 	local ft = ok and vim.api.nvim_buf_get_option(buf, "filetype") or "?"
-- 	print("[DEBUG] Set width:", width, "WinID:", winid, "FT:", ft, "Stack:", debug.traceback("", 2))
-- 	return original_set_width(winid, width)
-- end

-- TODO: LuaRocks loader not found fix this later so that I will not need the script below it
-- local ok, result = pcall(require, "luarocks.loader")
-- print("LuaRocks loader status:", ok, result)

-- Load LuaRocks paths manually
local function add_luarocks_paths()
	local home = os.getenv("HOME")
	local paths = {
		home .. "/.luarocks/share/lua/5.1/?.lua",
		home .. "/.luarocks/share/lua/5.1/?/init.lua",
		home .. "/.luarocks/lib/lua/5.1/?.so",
	}

	for _, path in ipairs(paths) do
		if not string.find(package.path, path, 1, true) then
			package.path = package.path .. ";" .. path
		end
		if not string.find(package.cpath, path, 1, true) then
			package.cpath = package.cpath .. ";" .. path
		end
	end
end

add_luarocks_paths()

vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.opt.list = true
-- Optional: customise how they look
vim.opt.listchars = {
	tab = "▸ ", -- “▸␉” is also popular
	trail = "·",
	space = "·",
	extends = "⟩",
	precedes = "⟨",
	nbsp = "␣",
}
vim.o.exrc = true -- allow project-local config
vim.o.secure = true -- block risky calls in sandboxed mode
vim.o.wrap = false
vim.o.maxmempattern = 5000 -- Max mem pattern for searches, Neogit seems to have problem with the default 1000, so set it to 5000
vim.o.laststatus = 3 -- Always show a global statusline at the bottom
-- NOTE: not sure yet if I'll need this to prevent warning messages
-- set conceallevel to 2 for better link visibility
-- vim.api.nvim_buf_set_option(bufnr, "conceallevel", 2)
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "Dockerfile*",
	callback = function() end,
})

---- vim-visual-multi
-- Set key bindings for vim-visual-multi
vim.g.VM_maps = {
	["Find Under"] = "<M-v>",
	["Find Subword Under"] = "<M-v>",
	-- ["Find Under"] = "´",
	-- ["Find Subword Under"] = "´",
	["Add Cursor Down"] = "+",
	["Add Cursor Up"] = "_",
}

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

require("user.workspace_symbol_live")
-- TODO: Move this to proper key setup
vim.keymap.set("n", "<leader>fw", function()
	vim.cmd("WorkspaceSymbolSearch")
end, { desc = "Live LSP Workspace Symbols" })
require("object").setup()
require("monkey-patches.avante")
require("user.autocommands")
require("user.commands")
require("core.options")
require("core.keymaps")
require("core.auto_splits_resize").setup()
require("watchers.direnv").setup()
-- helpers
local function get_hex_fg(group)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = true })
	if ok and hl and hl.fg then
		return string.format("#%06x", hl.fg)
	end
	return nil
end

local function pick_fg(groups)
	for _, g in ipairs(groups) do
		local fg = get_hex_fg(g)
		if fg then
			return fg
		end
	end
	return nil
end

vim.highlight.priorities.semantic_tokens = 250

-- cache of ORIGINAL scheme colors (per colorscheme)
local cache = { scheme = nil, param_fg = nil, var_fg = nil }

local function compute_base_colors()
	-- read only from scheme/TS groups (not from @lsp.* that we modify)
	local param_fg = pick_fg({ "@variable.parameter", "@parameter", "TSParameter", "Identifier" })
	local var_fg = pick_fg({ "@variable", "TSVariable", "Identifier" })

	return param_fg, var_fg
end

local function apply_custom()
	-- Example: keep parameters as-is, make non-parameter variables white
	-- (Change to your desired behavior. If you want the “swap”, use cache.var_fg for params.)
	-- keep params red everywhere; locals/globals use the other color
	if vim.g.colors_name == "base16-ayu-mirage" then
		vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = cache.var_fg })
		vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = cache.param_fg, italic = true })
		vim.api.nvim_set_hl(0, "@lsp.typemod.parameter.declaration", { fg = cache.param_fg, italic = true })
		vim.api.nvim_set_hl(0, "@lsp.typemod.parameter.readonly", { fg = cache.param_fg, italic = true })

		-- some servers mark params as variable+readonly; make that a param color too
		vim.api.nvim_set_hl(0, "@lsp.typemod.variable.readonly", { fg = cache.param_fg, italic = true })

		-- fallbacks when semantic tokens are missing
		vim.api.nvim_set_hl(0, "@variable.parameter", { fg = cache.var_fg, italic = true })
		vim.api.nvim_set_hl(0, "@variable", { fg = cache.param_fg })
	end

	-- your other tweaks
	local hl = vim.api.nvim_get_hl(0, { name = "@lsp.type.namespace", link = true })
	vim.api.nvim_set_hl(0, "@lsp.type.namespace", {
		fg = hl.fg, -- reuse original color
		underline = true,
	})
	hl = vim.api.nvim_get_hl(0, { name = "TSMethod", link = true })
	vim.api.nvim_set_hl(0, "TSPunctBracket", { link = "TSMethod" })
	vim.api.nvim_set_hl(0, "@punctuation.bracket", { link = "TSMethod" })

	vim.api.nvim_set_hl(0, "Whitespace", { fg = "#595D6C", nocombine = true })
	vim.api.nvim_set_hl(0, "NonText", { fg = "#595D6C", nocombine = true })
	vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#ee7777", nocombine = true })
end

local grp = vim.api.nvim_create_augroup("MyHLOncePerScheme", { clear = true })

-- Recompute ONLY when colorscheme changes (or on first start)
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
	group = grp,
	callback = function()
		cache.scheme = vim.g.colors_name or "default"
		cache.param_fg, cache.var_fg = compute_base_colors()
		-- If we failed to detect colors, bail gracefully
		if not cache.param_fg or not cache.var_fg then
			return
		end
		apply_custom()
	end,
})

-- Reapply (without recomputing) on LSP attach / Go files opening
vim.api.nvim_create_autocmd({ "LspAttach", "FileType" }, {
	group = grp,
	pattern = { "go" },
	callback = function()
		if cache.param_fg and cache.var_fg then
			apply_custom()
		end
	end,
})

--- Colorscheme
-- Dark themes
-- vim.cmd([[colorscheme nordfox]])
-- vim.cmd([[colorscheme dawnfox]])
-- vim.cmd([[colorscheme base16-zenburn]])
-- vim.cmd([[colorscheme base16-espresso]])
-- vim.cmd([[colorscheme base16-hopscotch]])
-- vim.cmd([[colorscheme base16-everforest]])
-- vim.cmd([[colorscheme base16-sandcastle]])
-- vim.cmd([[colorscheme base16-schemer-medium]])
-- vim.cmd([[colorscheme base16-rose-pine-moon]])
-- vim.cmd([[colorscheme base16-rose-pine]])
-- vim.cmd([[colorscheme base16-tomorrow-night]])
-- vim.cmd([[colorscheme base16-egde-dark]])
-- vim.cmd([[colorscheme base16-twilight]])
-- vim.cmd([[colorscheme duskfox]])
-- vim.cmd([[colorscheme gruvbox]])
vim.cmd([[colorscheme base16-ayu-mirage]])

-- Light themes
-- vim.cmd([[colorscheme base16-ayu-light]])
-- vim.cmd([[colorscheme base16-egde-light]])
-- vim.cmd([[colorscheme base16-primer-light]])
-- vim.cmd([[colorscheme base16-harmonic-light]])
-- vim.cmd([[colorscheme base16-sage-light]])
-- vim.cmd([[colorscheme base16-github]])

---- Overseer
-- Load project-local Overseer tasks from .nvim.lua
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local path = vim.fn.getcwd() .. "/.nvim.lua"
		if vim.fn.filereadable(path) == 1 then
			local ok, templates = pcall(dofile, path)
			if ok and type(templates) == "table" then
				for _, t in ipairs(templates) do
					require("overseer").register_template(t)
				end
			else
				print("Failed to load .nvim.lua:", templates)
			end
		end
	end,
})

-- TODO: Find a way to hot reload Overseer templates, below does not work as expected
-- Reload task templates on BufWritePost for .nvim.lua files

---- For neovide
-- Make Option+key work as Meta in Neovide on macOS
vim.g.neovide_input_macos_option_key_is_meta = "only_left"
---- Command key combinations
-- paste
vim.keymap.set({ "n", "v", "i", "c" }, "<D-v>", function()
	vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end)
-- copy
vim.keymap.set({ "v" }, "<C-c>", '"+y', { desc = "Copy to system clipboard" })
-- cut
vim.keymap.set({ "v" }, "<D-x>", '"+d', { desc = "Cut to system clipboard" })
-- Select all
vim.keymap.set("n", "<D-a>", "ggVG", { desc = "Select All" })
