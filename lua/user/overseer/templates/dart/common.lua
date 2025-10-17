local M = {}

M.condition = {
	callback = function()
		local is_cwd = vim.fn.filereadable("pubspec.yaml") == 1
		local is_buffer_type = vim.bo.filetype == "dart"
		return is_cwd or is_buffer_type
	end,
}

M.get_connected_devices = function()
	local devices = {}
	local handle = io.popen("flutter devices")
	-- TODO: This code seems to make nvim session broken, checked why, find a way
	-- Because when it is broken, you can't even do :mes to see the messages, may be checked out how to catch errors from io.popen
	-- Below is the example output of the `flutter devices` command:
	--   iPhone 16 Plus (mobile) • DD718957-595C-4F2D-8B76-E3DD6005C5BB • ios            • com.apple.CoreSimulator.SimRuntime.iOS-18-6 (simulator)
	--   macOS (desktop)         • macos                                • darwin-arm64   • macOS 15.5 24F74 darwin-arm64
	--   Chrome (web)            • chrome                               • web-javascript • Google Chrome 141.0.7390.108
	-- So we need to parse the output to extract structure as name,id,platform,details
	if handle then
		for line in handle:lines() do
			local name, id, platform, details = line:match("^%s*(.-)%s+•%s+(.-)%s+•%s+(.-)%s+•%s+(.-)%s*$")
			local device = {
				name = name,
				id = id,
				platform = platform,
				details = details,
			}
			if name and id and platform and details then
				table.insert(devices, device)
			end
		end
		handle:close()
	end
	return devices
end

return M
