local path_util = require("utils.path")
local common = require("user.overseer.templates.go.common")
local state = require("user.overseer.state")
local template_name = "Go: 1. Run"
return {
	name = template_name,
	condition = common.condition,
	params = function()
		local root, files = path_util.root_and_files_under_pattern("go.mod", "go")
		-- Before root changes, we want to convert files to relative paths (it has the last segment of the path)
		files = path_util.convert_to_relative_path(root)(files)
		root = path_util.convert_to_relative_path()(root)
		-- Find main.go file if it exists in files
		local main_file = vim.iter(files):find(function(file)
			return file:match("main%.go$")
		end)
		local last_params = state.get_last_params(template_name)
		return {
			file = {
				type = "string",
				default = last_params.file or main_file,
				choices = files,
				desc = "Go file to run",
			},
			root = { type = "string", default = last_params.root or root, desc = "Root directory for the Go project" },
			args = {
				type = "list",
				optional = true,
				default = last_params.args or {},
				desc = "Arguments to pass to the program",
			},
			debug = { type = "boolean", default = last_params.debug or false, desc = "Run in debug mode" },
		}
	end,
	builder = function(params)
		state.set_last_params(template_name, params)
		local components = {
			"default",
			-- TODO: make this component common in go templates, along with cwd below
			{
				"on_output_quickfix",
				errorformat = "%f:%l:%c:%m",
				-- Remove the default errorformat override and define your own:
				-- errorformat = table.concat({
				-- 	"%f:%l %m",
				-- }, ","),
			},
			-- TODO: Update this qf.tail component to process the output in background, so it doesn't block the UI
			-- { "qf.tail" },
		}
		if params.debug then
			vim.defer_fn(function()
				-- TODO: Wrap this in dap.functions instead
				local dap = require("dap")
				for _, config in ipairs(dap.configurations.go or {}) do
					if config.name == "Launch remote" then
						local launch = vim.deepcopy(config)
						-- TODO: This needs to be enhanched, because like this it is assuming that user did not change
						--       the params.root, then this absolute_root will coincide with the params.root as it's absolute.
						-- local absolute_root = path_util.get_root_with_pattern("go.mod")
						-- launch.program = absolute_root .. "/" .. params.file
						-- NOTE: Not sure yet if we'll need to use absolute paths here, so for now we use the relative path
						launch.program = params.file
						dap.run(launch)
						return
					end
				end
				vim.notify("[dap] Could not find configuration 'Launch remote'", vim.log.levels.ERROR)
			end, 300)

			return {
				name = "dlv dap server",
				cmd = { "dlv" },
				args = {
					"dap",
					"--listen=127.0.0.1:38697",
					"--api-version=2",
					"--log",
				},
				components = components,
				-- TODO: make this component common in go templates, along with component above
				cwd = params.root, -- NOTE: This may breaks later on, if params.root is not relative to the cwd anymore
			}
		else
			return {
				strategy = "jobstart",
				name = "Run " .. params.file .. " in " .. params.root,
				cmd = { "go" },
				args = {
					"run",
					params.file,
					unpack(params.args or {}),
				},
				components = components,
				cwd = params.root, -- NOTE: This may breaks later on, if params.root is not relative to the cwd anymore
			}
		end
	end,
}
