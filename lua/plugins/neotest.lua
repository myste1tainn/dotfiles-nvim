-- Setup for neotest
return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-neotest/nvim-nio",
			-- "myste1tainn/neotest-go", -- Supports only basic go testing, suite not supported, output panel raw JSON, unreadable, need to configure yourself (forked-patching)
			"nvim-neotest/neotest-python",
			"nvim-neotest/neotest-vim-test",
			{
				"fredrikaverpil/neotest-golang",
				dependencies = {
					{
						"andythigpen/nvim-coverage",
						version = "*",
						config = function()
							require("coverage").setup({
								auto_reload = true,
							})
						end,
					},
					-- 1. plugins.lua / lazy spec ---------------------------------------
					{
						"uga-rosa/utf8.nvim", -- needed only when some plugin requires it
						lazy = true, -- load on first `require("utf8")`
					},
				},
			},
		},

		config = function()
			-- TODO: Tidy up this hacky code somewhere, forked patch if needed
			local golang = require("neotest-golang")({
				runner = "gotestsum",
				runner_strategy = {
					dap = "go",
					go_test_args = {
						"-json",
						"-v",
						"-race",
						"-count=1",
						"-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
					},
				},
				go_test_args = {
					"-json",
					"-v",
					"-race",
					"-count=1",
					"-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
				},
				gotestsum_args = {
					"--format=standard-verbose",
					-- "--jsonfile",
					-- "--",
				},
				-- gotestsum_args = { "--format=testname" },
				-- sanitize_output = true,
				testify_enabled = true,
				stream = true,
				dap = {
					console = "integratedTerminal", -- or "externalTerminal"
					justMyCode = false, -- only debug code that is not part of the standard library
					showLog = true, -- show debug log in the output panel
					setup = function(config)
						config.init = false
						config.initialized_timeout_sec = 20
						config.stopOnEntry = false
						print("config got called")
						return config
					end,
				},
			})
			-- wrap the adapter's result‐parsing fn
			local orig_result = golang.results

			golang.results = function(spec, output, tree)
				local results = orig_result(spec, output, tree) or {}

				local function normalize(target)
					-- TODO: This is unreliable, because the file name can be the same in different directories.
					--       But have to be like this because gotestsum doesn't provide relative path to the file.
					--       It just says file name that has the error.
					--       The solution that would make sense is to look at the neotest / neotest-golang the raw output that is ran
					--       If it mentions the full relative path, then we can use that.
					local hits = vim.fs.find(
						target,
						{
							path = vim.uv.cwd(), -- search under current working dir
							type = "file", -- only files (not dirs)
							limit = 1,
						} -- stop at first match
					)
					local full_path = hits[1] -- nil if not found
					return full_path or target
				end

				-- smarter parser ─────────────────────────────────────────────────────
				local function collect_errors(filepath)
					-- turn "filepath" (a filename or a string) into plain text ------------
					local text = filepath
					if type(filepath) == "string" and vim.fn.filereadable(filepath) == 1 then
						text = table.concat(vim.fn.readfile(filepath), "\n")
					end
					if type(text) ~= "string" then
						return {}
					end

					local errs = {}
					local pat = "^%s*([%w%./_%-%d]+%.go):(%d+):%s*(.*)" -- path.go:ln: msg

					for line in text:gmatch("[^\r\n]+") do
						local file, ln, msg = line:match(pat)
						if file then
							ln = tonumber(ln)

							----------------------------------------------------------------
							-- If the *message itself* embeds a deeper location
							--   … foo.go:137: missing call … /full/path/bar_test.go:192
							-- grab the *last* path:line pair inside that message.
							----------------------------------------------------------------
							local deep_file, deep_ln
							for p, l in msg:gmatch("([%w%./_%-%d]+%.go):(%d+)") do
								deep_file, deep_ln = p, tonumber(l)
							end
							if deep_file then
								file, ln = deep_file, deep_ln
							end

							table.insert(errs, {
								-- TODO: path and lnum don't actually works, have to modify neotest itself also, it some how ignore this field, and use bufnr i guess?
								path = normalize(file),
								lnum = ln, -- quickfix is 1-based already
								column = 1,
								message = msg,
							})
						end
					end
					return errs
				end
				--------------------------------------------------------------------

				-- augment every test-case result with richer errors
				for _, res in pairs(results) do
					-- keep what the adapter already gave us, just add/replace .errors
					res.errors = collect_errors(res.output or "")
				end
				return results
			end

			------------------------------------------------------------------------
			--  B)  Monkey-patch the quick-fix consumer **after** neotest is loaded
			------------------------------------------------------------------------
			local qf = require("neotest.consumers.quickfix")
			local base_list = qf.build_qf_list

			qf.build_qf_list = function(results)
				local list = base_list(results)
				for _, item in ipairs(list) do
					local err = item.neotest_error
					if err and err.path then
						item.filename = err.path
						item.lnum = err.line
						item.col = err.column or 1
					end
				end
				return list
			end

			---@diagnostic disable-next-line: missing-fields
			require("neotest").setup({
				---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
				quickfix = { open = "auto" },
				---@diagnostic disable-next-line: missing-fields
				status = { enabled = true },
				---@diagnostic disable-next-line: missing-fields
				output = { enabled = true },
				---@diagnostic disable-next-line: missing-fields
				summary = { enabled = true },
				adapters = {
					golang,
					require("neotest-python"),
					-- require("neotest-vim-test")({
					-- 	ignore_file_types = { "lua", "javascript" },
					-- }),
				},
			})
		end,
	},
}
