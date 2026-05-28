return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			format_after_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
				async = true,
			},
			formatters_by_ft = {
				-- go = { "goimports" },
				go = { "gofumpt" },
				python = { "black" },
				lua = { "stylua" },
				ruby = { "rubocop" },
				-- dart = { "dart_format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
				xml = { "prettierxml" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				java = { "google-java-format" },
				rust = { "rustfmt" },
				starlark = { "buildifier" },
				yaml = { "prettier" },
			},
			formatters = {
				-- NOTE: Below prettier is from npm install -g, further below comes from Mason
				prettierxml = {
					command = "/usr/local/bin/prettier",
					args = {
						"--plugin=@prettier/plugin-xml",
						"--wrap-attributes-threshold=3",
						"--stdin-filepath",
						"$FILENAME",
					},
					stdin = true,
					timeout_ms = 10000,
				},
				prettier = {
					command = "prettier",
					args = {
						"--stdin-filepath",
						"$FILENAME",
					},
					stdin = true,
				},
				-- dart_format = {
				-- command = "dart",
				-- args = { "format", "--output", "show", "--line-length", "80", "$FILENAME" },
				-- stdin = true,
				-- timeout_ms = 10000, -- 10 seconds
				-- },
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
