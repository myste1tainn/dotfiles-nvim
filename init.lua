vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.o.exrc = true -- allow project-local config
vim.o.secure = true -- block risky calls in sandboxed mode
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "Dockerfile*",
	callback = function()
		vim.bo.filetype = "dockerfile"
	end,
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
