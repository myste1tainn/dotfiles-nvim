vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.o.exrc = true -- allow project-local config
vim.o.secure = true -- block risky calls in sandboxed mode
vim.o.wrap = false
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
