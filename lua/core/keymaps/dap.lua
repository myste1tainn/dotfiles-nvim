local dap = require("dap")
local dapui = require("dapui")
local keymap = vim.keymap.set

return function(bufnr)
	-- Toggle
	keymap("n", "<leader>dt", function()
		dapui.toggle()
	end, { desc = "DapUI: Toggle", silent = true })

	-- Open
	keymap("n", "<leader>do", function()
		dapui.open()
	end, { desc = "DapUI: Open", silent = true })

	-- Focus
	keymap("n", "<leader>df", function()
		dapui.focus()
	end, { desc = "DapUI: Focus", silent = true })

	-- Close
	keymap("n", "<leader>dc", function()
		dapui.close()
	end, { desc = "DapUI: Close", silent = true })

	-- Continue/Step Over/Step Into/Step Out
	keymap("n", "<leader>pc", dap.continue, { desc = "Dap: Continue", silent = true })
	keymap("n", "<leader>po", dap.step_over, { desc = "Dap: Step Over", silent = true })
	keymap("n", "<leader>pi", dap.step_into, { desc = "Dap: Step Into", silent = true })
	keymap("n", "<leader>pO", dap.step_out, { desc = "Dap: Step Out", silent = true })

	-- Toggle Breakpoint
	keymap({ "n", "v" }, "<M-\\>", dap.toggle_breakpoint, { desc = "Dap: Toggle Breakpoint", silent = true })
	keymap({ "i" }, "<M-\\>", function()
		-- In insert mode, we need to exit insert mode first
		vim.cmd("stopinsert")
		dap.toggle_breakpoint()
		-- then go back to insert mode, have to delay it a bit to avoid issues
		vim.defer_fn(function()
			if vim.api.nvim_get_mode().mode == "i" then
				return
			end
			vim.cmd("startinsert")
		end, 10)
	end, { desc = "Dap: Toggle Breakpoint", silent = true })
end
