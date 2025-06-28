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

require("core.options")
require("core.keymaps")
require("core.auto_splits_resize").setup()
-- vim.cmd([[colorscheme gruvbox]])
vim.cmd([[colorscheme nordfox]])
-- Pick a subtle colour from your palette
-- local grey = "#586875"
--
-- vim.api.nvim_set_hl(0, "Whitespace", { fg = grey, nocombine = true })
-- vim.api.nvim_set_hl(0, "NonText", { fg = grey, nocombine = true })

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
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.nvim.lua",
	callback = function()
		vim.cmd("luafile %")
		require("overseer").clear_task_cache()
		require("overseer.template").cache = {} -- ⚠ force wipe
		require("overseer.template").user_template_provider = nil -- if using user templates
		vim.notify("Overseer templates reloaded", vim.log.levels.INFO)
	end,
})
