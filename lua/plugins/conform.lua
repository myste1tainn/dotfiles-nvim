return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				go = { "gofmt" },
				python = { "black" },
				lua = { "stylua" },
				javascript = { "prettier" },
				ruby = { "rubocop" },
				dart = { "dartfmt" },
			},
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})
	end,
}
