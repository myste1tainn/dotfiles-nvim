local path_util = require("utils.path")
local common = require("user.overseer.templates.rust.common")
local template_name = "Rust: 2. Build"
return {
	name = template_name,
	condition = common.condition,
	params = function()
		local root = path_util.get_root_with_pattern("Cargo.toml")
		root = path_util.convert_to_relative_path()(root)
		return {
			root = { type = "string", default = root, desc = "Root directory for the Rust project" },
			args = {
				type = "list",
				optional = true,
				default = {},
				desc = "Arguments to pass to cargo build",
			},
		}
	end,
	builder = function(params)
		return {
			strategy = "jobstart",
			name = "Cargo Build in " .. params.root,
			cmd = { "cargo" },
			args = vim.list_extend({ "build" }, params.args or {}),
			components = {
				"default",
				{ "on_output_quickfix", errorformat = "%f:%l:%c: %m" },
			},
			cwd = params.root,
		}
	end,
}
