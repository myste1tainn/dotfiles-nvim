return {
	"hrsh7th/cmp-nvim-lsp",
	-- `lsp.setup` registers the servers and the FileType → vim.lsp.start
	-- autocmd. Left to nvim-cmp's InsertEnter/CmdlineEnter load it ran long
	-- after the startup buffer's FileType had fired, so the first file opened
	-- got no client at all.
	event = "VeryLazy",
	-- mason prepends its bin dir to PATH in its own config, and `lsp.setup`
	-- starts servers from that PATH — so mason has to be configured first.
	dependencies = { "mason-org/mason.nvim" },
	config = function()
		-- TODO: Refactor and combine into nvim-cmp setup and make mason part of its dependencies
		require("lsp.setup")
		require("core.diagnostics")()
	end,
}
