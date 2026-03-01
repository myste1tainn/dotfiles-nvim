return {
	compose = function(...)
		local funcs = { ... }
		return function(input)
			local result = input
			for _, fn in ipairs(funcs) do
				result = fn(result)
			end
			return result
		end
	end,
}
