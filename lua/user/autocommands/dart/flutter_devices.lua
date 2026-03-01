local scan_device = require("user.devctx.flutter.scan_device")
-- Start only when the cwd is a flutter project
local cwd = vim.fn.getcwd()
if vim.fn.filereadable(cwd .. "/pubspec.yaml") == 1 then
	scan_device.scan(2000)
end

vim.api.nvim_create_user_command("SimDevicesStop", function()
	scan_device.stop()
end, {})
