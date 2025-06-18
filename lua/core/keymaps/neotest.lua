local neotest = require("neotest")
local keymap = vim.keymap.set
local neotest_fns = require("user.neotest.functions")

return function(bufnr)
	-- Output and summary toggles
	keymap("n", "<leader>tt", function()
		neotest.output_panel.toggle()
		neotest.summary.toggle()
	end, { desc = "Toggle output_panel and summary", silent = true })

	-- Open actions
	keymap("n", "<leader>to", neotest_fns.open, { desc = "Open output_panel and summary", silent = true })

	-- Close actions
	keymap("n", "<leader>tc", function()
		neotest.output_panel.close()
		neotest.summary.close()
	end, { desc = "Close output_panel and summary", silent = true })

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
	keymap("n", "<leader>trl", neotest.run.run_last, { desc = "Run last test", silent = true })
end
