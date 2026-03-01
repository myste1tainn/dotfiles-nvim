local ctx = require("user.devctx.flutter")

local function upsert_device(device)
	for i, d in ipairs(ctx.devices) do
		if d.udid == device.udid then
			ctx.devices[i] = device
			return
		end
	end
	table.insert(ctx.devices, device)
end

return upsert_device
