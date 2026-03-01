local M = {}

M.condition = {
	filetype = { "dart", "flutter" },
	-- callback = function()
	-- 	local is_cwd = vim.fn.filereadable("pubspec.yaml") == 1
	-- 	local is_buffer_type = vim.bo.filetype == "dart"
	-- 	return is_cwd or is_buffer_type
	-- end,
}

M.get_connected_devices = function()
	local ctx = require("user.devctx.flutter")
	local devices = {}
	for i, d in pairs(ctx.devices) do
		table.insert(devices, {
			name = d.name,
			id = d.udid,
			platform = d.platform,
			details = d.runtime,
		})
	end
	return devices
end

return M
