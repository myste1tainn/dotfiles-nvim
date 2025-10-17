-- Keymaps that should be avaible at all times
require("core.keymaps.core")()
require("core.keymaps.fzf-lua")()
require("core.keymaps.nvim-spectre")()
require("core.keymaps.toggleterm")()
require("core.keymaps.neogit")()

-- If the root contains pubspec.yaml or the opened buffer is a Dart file, load Flutter keymaps
-- Otherwise, load Overseer keymaps
-- if vim.fn.filereadable("pubspec.yaml") == 1 or vim.bo.filetype == "dart" then
-- 	require("core.keymaps.flutter")()
-- else
require("core.keymaps.overseer")()
-- end

-- Keymaps that avaible with LSP active
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		require("core.keymaps.lspsaga")(args.buf)

		-- If there's no LSP client attoched, it doesn't make sense to load these keymaps
		require("core.keymaps.neotest")(args.buf)
		require("core.keymaps.dap")(args.buf)
	end,
})
