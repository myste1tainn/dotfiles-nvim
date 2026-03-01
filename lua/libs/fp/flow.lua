-- flow.lua (or inline in your module)
local Flow = {}
Flow.__index = Flow

-- source: function(cb) ... cb(value) end
function Flow.from_async(source)
	return setmetatable({ source = source, ops = {} }, Flow)
end

function Flow:filter(pred)
	table.insert(self.ops, function(next)
		return function(x)
			if pred(x) then
				next(x)
			end
		end
	end)
	return self
end

function Flow:map(f)
	table.insert(self.ops, function(next)
		return function(x)
			next(f(x))
		end
	end)
	return self
end

function Flow:schedule()
	table.insert(self.ops, function(next)
		return function(x)
			vim.schedule(function()
				next(x)
			end)
		end
	end)
	return self
end

-- dedupe by key; keep state in user-provided get/set closures
function Flow:dedupe(key_fn, get_last, set_last)
	table.insert(self.ops, function(next)
		return function(x)
			local k = key_fn(x)
			if k == get_last() then
				return
			end
			set_last(k)
			next(x)
		end
	end)
	return self
end

function Flow:tap(effect)
	table.insert(self.ops, function(next)
		return function(x)
			effect(x)
			next(x)
		end
	end)
	return self
end

-- produce a zero-arg runner suitable for timer/start, mappings, commands, etc.
function Flow:run()
	local cb = function(_) end
	for i = #self.ops, 1, -1 do
		cb = self.ops[i](cb)
	end
	return function()
		self.source(cb)
	end
end

return Flow
