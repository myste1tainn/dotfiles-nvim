local path_util = require("utils.path")
local common = require("user.overseer.templates.dart.common")
local template_name = "Flutter: 1. Run"

function device_choices()
	local choices = {}
	local devices = common.get_connected_devices()
	for _, d in ipairs(devices) do
		table.insert(choices, string.format("%s (%s) - %s", d.name, d.details, d.platform))
	end
	return choices
end

local function file_choices()
	local root, files = path_util.root_and_files_under_pattern("pubspec.yaml", "dart")
	files = path_util.convert_to_relative_path(root)(files)
	root = path_util.convert_to_relative_path()(root)
	files = vim.iter(files)
		:filter(function(file)
			return file:match("/main.*%.dart$")
		end)
		:totable()
	local main_file = vim.iter(files):find(function(file)
		return file:match("/main%.dart$")
	end) or files[1]
	return main_file, files
end

return {
	name = template_name,
	condition = common.condition,
	params = function()
		local main_file, files = file_choices()
		return {
			main = {
				type = "enum",
				choices = files,
				default = main_file or "lib/main.dart",
				desc = "Main entry file",
			},
			device = {
				type = "string",
				choices = device_choices(),
				optional = false,
				default = nil,
				desc = "Device ID to run the app on, empty for default device",
			},
			debug = { type = "boolean", default = false, desc = "Run in debug mode" },
		}
	end,
	builder = function(params)
		local components = {
			-- "default",
			-- {
			-- 	"on_output_quickfix",
			-- 	errorformat = "%f:%l:%c:%m",
			-- },
		}
		local device_id = nil
		if params.device ~= "" then
			local name, details, platform = params.device:match("^(.-) %((.-)%) %- (.-)$")
			for _, d in ipairs(common.get_connected_devices()) do
				if d.name == name and d.details == details and d.platform == platform then
					device_id = d.id
					break
				end
			end
		end
		if not device_id then
			-- throw error if device_id is not found
			vim.notify("Device not found: " .. params.device, vim.log.levels.ERROR)
			return
		end
		if params.debug then
		-- TODO: Implement debug run configuration
		else
			return {
				strategy = "jobstart",
				name = "flutter run",
				cmd = { "flutter" },
				args = {
					"run",
					"--target=" .. params.main,
					unpack({ "-d", device_id }),
				},
				components = components,
			}
		end
	end,
}
