local path_util = require("utils.path")
local common = require("user.overseer.templates.go.common")
local state = require("user.overseer.state")

local template_name = "2. Go: Build"

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
				default = last_params.file or main_file or "./...",
				choices = files,
				desc = "Go file to build",
			},
			root = { type = "string", default = last_params.root or root, desc = "Root directory for the Go project" },
			args = {
				type = "string",
				optional = true,
				default = last_params.args or {},
				desc = "Arguments to pass to the program",
			},
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
		return {
			strategy = "jobstart",
			name = "Build " .. params.file .. " in " .. params.root,
			cmd = { "go" },
			args = {
				"build",
				params.file,
				unpack(params.args or {}),
			},
			components = components,
			cwd = params.root, -- NOTE: This may breaks later on, if params.root is not relative to the cwd anymore
		}
	end,
}
