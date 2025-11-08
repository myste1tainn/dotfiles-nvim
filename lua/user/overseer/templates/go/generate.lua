local path_util = require("utils.path")
local common = require("user.overseer.templates.go.common")
local state = require("user.overseer.state")
local template_name = "Go: 4. Generate"
return {
	name = template_name,
	condition = common.condition,
	params = function()
		local root, files = path_util.root_and_files_under_pattern("go.mod", "go")
		-- Before root changes, we want to convert files to relative paths (it has the last segment of the path)
		files = path_util.convert_to_relative_path(root)(files)
		root = path_util.convert_to_relative_path()(root)
		local last_params = state.get_last_params(template_name)
		return {
			root = { type = "string", default = last_params.root or root, desc = "Root directory for the Go project" },
		}
	end,
	builder = function(params)
		state.set_last_params(template_name, params)
		local components = { "default", { "on_output_quickfix", errorformat = "%f:%l:%c:%m" } }
		return {
			strategy = "jobstart",
			name = "Go Generate in " .. params.root,
			cmd = { "go" },
			args = { "generate", "./..." },
			components = components,
			cwd = params.root, -- NOTE: This may breaks later on, if params.root is not relative to the cwd anymore
		}
	end,
}
