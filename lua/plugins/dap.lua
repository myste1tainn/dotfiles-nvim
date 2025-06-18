return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"leoluz/nvim-dap-go",
				config = function()
					return require("dap-go").setup({
						dap_configurations = {
							{
								type = "go",
								name = "Attach remote",
								mode = "remote",
								request = "attach",
								program = "${workspaceFolder}/bff-document-service-go/cmd/main.go",
								host = "127.0.0.1",
								port = 38697,
							},
							{
								type = "go",
								name = "Launch remote",
								request = "launch",
								program = "${workspaceFolder}/bff-document-service-go/cmd/main.go",
								host = "127.0.0.1",
								port = 38697,
							},
						},
						delve = {
							path = "dlv",
							initialize_timeout_sec = 20,
							-- host = "${host}",
							-- port = "${port}",
							host = "127.0.0.1",
							port = 38697,
							args = {},
							build_flags = {},
							detached = vim.fn.has("win32") == 0,
							cwd = nil,
						},
						tests = {
							verbose = false,
						},
					})
				end,
			},
			{
				"mfussenegger/nvim-dap-python",
				config = function()
					-- TODO: Config this later, this needs to be dynamic per project setup, poetry, venv, whatsoever
					-- TODO: Check this docs for test runner and stuffs https://codeberg.org/mfussenegger/nvim-dap-python
					--       Probably make more sense to call the stuffs in overseer templates
					require("dap-python").setup("/path/to/venv/bin/python")
				end,
			},
			{
				"rcarriga/nvim-dap-ui",
				config = function()
					local dap, dapui = require("dap"), require("dapui")
					dapui.setup()
					dap.listeners.after.event_initialized["dapui_config"] = function()
						dapui.open()
					end
					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close()
					end
					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close()
					end
				end,
			},
			{
				"theHamsta/nvim-dap-virtual-text",
				config = function()
					require("nvim-dap-virtual-text").setup({
						commented = true,
					})
				end,
			},
		},
		config = function()
			local dap = require("dap")
			-- Go adapter configuration
			dap.adapters.go = function(callback, config)
				print("dap.adapters.go got triggered with config:", vim.inspect(config))
				callback({
					type = "server",
					host = config.host or "127.0.0.1",
					port = config.port or 38697,
				})
			end
		end,
	},
}
