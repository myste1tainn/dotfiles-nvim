return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				-- go = { "goimports" },
				go = { "gofumpt" },
				python = { "black" },
				lua = { "stylua" },
				ruby = { "rubocop" },
				dart = { "dart_format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				java = { "google-java-format" },
				rust = { "rustfmt" },
				starlark = { "buildifier" },
			},
			formatters = {
				prettier = {
					command = "prettier",
					args = { "--stdin-filepath", "$FILENAME" },
					stdin = true,
				},
				dart_format = {
					-- command = "dart",
					-- args = { "format", "--output", "show", "--line-length", "80", "$FILENAME" },
					-- stdin = true,
					timeout_ms = 10000, -- 10 seconds
				},
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
