local neotest = require("neotest")
local keymap = vim.keymap.set
local neotest_fns = require("user.neotest.functions")
local keymap_util = require("utils.keymap")
local panes_util = require("utils.panes")
local trouble = require("trouble")
local function toggle_neotest()
	panes_util.toggle_pane({
		pane_open_predicate = {
			filetype = "neotest-output-panel",
		},
		on_pane_is_being_focused = function(win)
			neotest.output_panel.close()
			neotest.summary.close()
		end,
		on_pane_existed = function(win)
			-- Trouble's quickfix and neotest windowns are exclusive to each other for now
			-- Having them both is counterproductive
			trouble.close("quickfix")
			trouble.close("diagnostics")
			vim.api.nvim_set_current_win(win.winid)
		end,
		on_pane_not_existed = function()
			-- Trouble's quickfix and neotest windowns are exclusive to each other for now
			-- Having them both is counterproductive
			trouble.close("quickfix")
			trouble.close("diagnostics")
			neotest.output_panel.open()
			neotest.summary.open()
			panes_util.focus_win("neotest-output-panel")
		end,
	})
end

return function(bufnr)
	-- Output and summary toggles
	keymap("n", "<leader>tt", toggle_neotest, { desc = "Toggle output_panel and summary", silent = true })
	keymap_util.map_for_all_and_terminal("<M-7>", toggle_neotest, { desc = "Open NoiceAll", silent = true })

	-- Open actions
	keymap("n", "<leader>to", function()
		neotest.output.open({ enter = true })
	end, { desc = "Open output at cursor and focused it", silent = true })

	-- Close actions
	keymap("n", "<leader>tc", function()
		neotest.output_panel.close()
		neotest.summary.close()
	end, { desc = "Close output_panel and summary", silent = true })

	-- Clear panels
	keymap("n", "<leader>tl", function()
		neotest.output_panel.clear()
	end, { desc = "Clear output_panel", silent = true })

	keymap("n", "<leader>ts", neotest.summary.toggle, { desc = "Toggle test summary", silent = true })

	-- Test running commands
	keymap("n", "<leader>trn", neotest.run.run, { desc = "Run nearest test", silent = true })
	keymap("n", "<leader>trc", function()
		local file = vim.fn.expand("%")
		neotest.run.run(file)
		neotest_fns.open()
	end, { desc = "Run tests in the current file", silent = true })
	keymap("n", "<leader>trd", function()
		local file = vim.fn.expand("%")
		local directory = vim.fn.fnamemodify(file, ":p:h")
		neotest.run.run(directory)
		neotest_fns.open()
	end, { desc = "Run tests in the current directory", silent = true })
	keymap("n", "<leader>tdn", function()
		neotest.run.run({ strategy = "dap" })
	end, { desc = "Debug nearest test", silent = true })
	keymap("n", "<leader>tdc", function()
		local file = vim.fn.expand("%")
		neotest.run.run({ file, strategy = "dap" })
		neotest_fns.open()
	end, { desc = "Debug tests in the current file", silent = true })
	keymap("n", "<leader>tdd", function()
		local file = vim.fn.expand("%")
		local directory = vim.fn.fnamemodify(file, ":p:h")
		neotest.run.run({ directory, strategy = "dap" })
		neotest_fns.open()
	end, { desc = "Debug tests in the current directory", silent = true })
	keymap("n", "<leader>trl", neotest.run.run_last, { desc = "Run last test", silent = true })
	keymap("n", "<leader>cvv", "<Cmd>Coverage<CR>", { desc = "Show Coverage", silent = true })
	keymap("n", "<leader>cvc", "<Cmd>CoverageHide<CR>", { desc = "Hide Coverage", silent = true })
	keymap("n", "<leader>cvs", "<Cmd>CoverageSummary<CR>", { desc = "Show Coverage Summary", silent = true })
end
