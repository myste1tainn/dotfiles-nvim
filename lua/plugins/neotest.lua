function neotest_golang_setup()
	-- TODO: Tidy up this hacky code somewhere, forked patch if needed
	local neotest_golang = require("neotest-golang")({
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
				return config
			end,
		},
	})
	return neotest_golang
end

-- helper: absolute path (cheap; no fs.find if already absolute)
local function abs(path)
	if vim.fn.fnamemodify(path, ":p") == path then
		return path
	end
	return vim.fn.fnamemodify(vim.loop.cwd() .. "/" .. path, ":p")
end

local function collect_errors(text)
	if type(text) ~= "string" then
		return {}
	end

	local errs = {}
	local top_pat = "^%s*([%w%./_%-%d]+%.go):(%d+):%s*(.*)"

	for line in text:gmatch("[^\r\n]+") do
		local file, ln, msg = line:match(top_pat)
		if file then
			ln = tonumber(ln)

			-- drill deeper if msg embeds another path:line pair
			for p, l in msg:gmatch("([%w%./_%-%d]+%.go):(%d+)") do
				file, ln = p, tonumber(l)
			end

			table.insert(errs, {
				path = abs(file),
				line = ln, -- <-- correct key
				column = 1, -- 1-based
				message = msg,
			})
		end
	end
	return errs
end

local function setup_neotest(neotest_golang_adapter)
	-- Patched the neotest-golang adapter to collect errors from output
	-- local orig_results = neotest_golang_adapter.results
	-- neotest_golang_adapter.results = function(spec, output, tree)
	-- 	local results = orig_results(spec, output, tree) or {}
	-- 	for _, res in pairs(results) do
	-- 		res.errors = collect_errors(res.output or "")
	-- 	end
	-- 	return results
	-- end

	---@diagnostic disable-next-line: missing-fields
	require("neotest").setup({
		---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
		quickfix = { open = "failed" },
		---@diagnostic disable-next-line: missing-fields
		status = { enabled = true },
		---@diagnostic disable-next-line: missing-fields
		output = { enabled = true },
		---@diagnostic disable-next-line: missing-fields
		summary = { enabled = true },
		adapters = {
			neotest_golang_adapter,
			require("neotest-python"),
			-- require("neotest-vim-test")({
			-- 	ignore_file_types = { "lua", "javascript" },
			-- }),
		},
	})
end
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
			local neotest_golang = neotest_golang_setup()
			setup_neotest(neotest_golang)
		end,
	},
}
