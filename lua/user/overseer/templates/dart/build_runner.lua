local path_util = require("utils.path")
local common = require("user.overseer.templates.dart.common")
local state = require("user.overseer.state")
local template_name = "Flutter: 5. Dart Build Runner"

return {
	name = template_name,
	condition = common.condition,
	params = function()
		local last_params = state.get_last_params(template_name)
		return {
			subcommand = {
				type = "enum",
				default = last_params.subcommand,
				choices = {
					"build",
					"watch",
				},
				desc = "Root directory for the Dart project",
			},
			delete_conflicting_outputs = {
				type = "boolean",
				default = last_params.delete_conflicting_outputs or false,
				desc = "Whether to delete conflicting outputs",
			},
		}
	end,
	builder = function(params)
		state.set_last_params(template_name, params)
		return {
			strategy = "jobstart",
			name = "Dart Build Runner: " .. params.subcommand,
			cmd = { "dart" },
			args = vim.list_extend(
				{ "run", "build_runner", params.subcommand },
				params.delete_conflicting_outputs and { "--delete-conflicting-outputs" } or {}
			),
			components = { "default" },
		}
	end,
}
