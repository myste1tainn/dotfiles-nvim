return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- yamllint has no config file here, so it would otherwise use the
		-- stock default preset (line-length max 80, severity error).
		lint.linters.yamllint.args = {
			"-d",
			"{extends: default, rules: {line-length: {max: 120, allow-non-breakable-inline-mappings: true}}}",
			"--format",
			"parsable",
			"-",
		}

		lint.linters_by_ft = {
			yaml = { "yamllint" },
			make = { "mbake" },
			makefile = { "mbake" },
		}

		-- Run linting on these events
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
