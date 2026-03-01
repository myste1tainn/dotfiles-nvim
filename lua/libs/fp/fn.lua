local function is_nil(value)
	return value == nil
end

local function is_not_nil(value)
	return not is_nil(value)
end

local function lift_callback(fn, ...)
	local fixed = { ... }
	return function(next)
		local args = { unpack(fixed) }
		args[#args + 1] = next
		fn(unpack(args))
	end
end

return {
	is_nil = is_nil,
	is_not_nil = is_not_nil,
	lift_callback = lift_callback,
}
