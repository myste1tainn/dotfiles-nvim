local path_util = require("utils.path")
local common = require("user.overseer.templates.dart.common")
local template_name = "Flutter: 5. Dart Build Runner"

return {
	name = template_name,
	condition = common.condition,
	params = function()
		return {
			subcommand = {
				type = "enum",
				choices = {
					"build",
					"watch",
				},
				desc = "Root directory for the Dart project",
			},
			delete_conflicting_outputs = {
				type = "boolean",
				default = false,
				desc = "Whether to delete conflicting outputs",
			},
		}
	end,
	builder = function(params)
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
