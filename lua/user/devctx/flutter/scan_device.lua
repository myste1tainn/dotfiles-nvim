local Fp = require("libs.fp.fp")
local Fn = require("libs.fp.fn")
local Flow = require("libs.fp.flow")
local upsert_device = require("user.devctx.flutter.upsert_device")
local ctx = require("user.devctx.flutter")
local timer

local last_hash = nil
local function get_last_hash()
	return last_hash
end
local function set_last_hash(h)
	last_hash = h
end

local function split(str, sep)
	local result = {}
	for part in string.gmatch(str, "([^" .. sep .. "]+)") do
		table.insert(result, part)
	end
	return result
end

local function save(json_str)
	local data = vim.json.decode(json_str)
	local devices = data.devices or {}
	for runtime, list in pairs(devices) do
		local parts = split(runtime, ".")
		local runtime_name = parts[#parts] or runtime
		for _, d in ipairs(list) do
			local isSimulator = d.deviceTypeIdentifier and d.deviceTypeIdentifier:find("CoreSimulator")
			upsert_device({
				runtime = runtime_name,
				name = d.name,
				udid = d.udid,
				state = d.state or "Unknown",
				is_avaiable = d.isAvailable,
				platform = isSimulator and "iOS Simulator" or "iOS Device",
			})
		end
	end
end

local function scan(interval_ms)
	interval_ms = interval_ms or 1000
	if timer then
		return
	end
	timer = vim.uv.new_timer()
	timer:start(
		0,
		interval_ms,
		vim.schedule_wrap(
			Flow.from_async(
				Fn.lift_callback(vim.system, { "xcrun", "simctl", "list", "devices", "-j" }, { text = true })
			)
				:filter(function(out)
					return out.code == 0
				end)
				:map(function(out)
					return out.stdout
				end)
				:filter(Fn.is_not_nil)
				:schedule()
				:dedupe(vim.fn.sha256, get_last_hash, set_last_hash)
				:tap(save)
				:run()
		)
	)
end

local function stop()
	if not timer then
		return
	end
	timer:stop()
	timer:close()
	timer = nil
end

return {
	scan = scan,
	stop = stop,
}
