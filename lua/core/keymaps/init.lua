-- Keymaps that should be avaible at all times
require("core.keymaps.core")()
require("core.keymaps.fzf-lua")()
require("core.keymaps.nvim-spectre")()
require("core.keymaps.overseer")()
require("core.keymaps.toggleterm")()
require("core.keymaps.neogit")()

-- Keymaps that avaible with LSP active
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		require("core.keymaps.lspsaga")(args.buf)

		-- If there's no LSP client attoched, it doesn't make sense to load these keymaps
		require("core.keymaps.neotest")(args.buf)
		require("core.keymaps.dap")(args.buf)
	end,
})
