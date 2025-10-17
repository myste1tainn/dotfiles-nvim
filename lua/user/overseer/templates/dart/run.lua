local common = require("user.overseer.templates.dart.common")
local state = require("user.overseer.state")

local template_name = "1. Run"

return {
	name = template_name,
	condition = common.condition,
	params = function()
		local last_params = state.get_last_params(template_name)
		return {
			device = {
				type = "choices",
				optional = true,
				default = last_params.device or "",
				choices = common.get_connected_devices(),
				desc = "Device ID to run the app on, empty for default device",
			},
			debug = { type = "boolean", default = last_params.debug or false, desc = "Run in debug mode" },
		}
	end,
	builder = function(params)
		state.set_last_params(template_name, params)
		print(params.device)
		return {}
		-- local components = {
		-- 	"default",
		-- 	{
		-- 		"on_output_quickfix",
		-- 		errorformat = "%f:%l:%c:%m",
		-- 	},
		-- }
		-- if params.debug then
		-- -- TODO: Implement debug run configuration
		-- else
		-- 	return {
		-- 		strategy = "jobstart",
		-- 		name = "Run " .. params.file .. " in " .. params.root,
		-- 		cmd = { "flutter" },
		-- 		args = {
		-- 			"run",
		-- 			params.device ~= "" and { "-d", params.device } or {},
		-- 		},
		-- 		components = components,
		-- 	}
		-- end
	end,
}
