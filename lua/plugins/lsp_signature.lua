return {
	"ray-x/lsp_signature.nvim",
	event = "VeryLazy",
	opts = {
		bind = true,
		floating_window = true,
		fix_pos = false, -- set to false if it's not tracking properly
		hint_enable = false,
		handler_opts = {
			border = "rounded",
		},
		extra_trigger_chars = { "(", ",", " " }, -- helps catch mid-typing
		-- These two are critical for correct parameter tracking:
		always_trigger = true, -- makes sure it updates on each keystroke
	},
	config = function(_, opts)
		-- TODO: Check back later if this is actually working, it seems like noice popup more than this
		require("lsp_signature").setup(opts)

		-- Forcefully disable the default LSP signature handler AFTER setup
		vim.schedule(function()
			vim.lsp.handlers["textDocument/signatureHelp"] = function() end
		end)
	end,
}
