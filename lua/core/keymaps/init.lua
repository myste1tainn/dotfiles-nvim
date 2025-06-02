-- Keymaps that should be avaible at all times
require("core.keymaps.core")()
require("core.keymaps.fzf-lua")()
require("core.keymaps.nvim-spectre")()
require("core.keymaps.overseer")()
require("core.keymaps.toggleterm")()

-- Keymaps that avaible with LSP active
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		require("core.keymaps.lspsaga")(args.buf)
	end,
})
