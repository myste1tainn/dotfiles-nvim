local LSP_KIND = {
	[1] = "File",
	[2] = "Module",
	[3] = "Namespace",
	[4] = "Package",
	[5] = "Class",
	[6] = "Method",
	[7] = "Property",
	[8] = "Field",
	[9] = "Constructor",
	[10] = "Enum",
	[11] = "Interface",
	[12] = "Function",
	[13] = "Variable",
	[14] = "Constant",
	[15] = "String",
	[16] = "Number",
	[17] = "Boolean",
	[18] = "Array",
	[19] = "Object",
	[20] = "Key",
	[21] = "Null",
	[22] = "EnumMember",
	[23] = "Struct",
	[24] = "Event",
	[25] = "Operator",
	[26] = "TypeParameter",
}

-- shorten filename to last 2 segments
local function shorten_filename(filename)
	local short
	if filename ~= nil then
		local parts = vim.split(filename, "/")
		if #parts >= 2 then
			short = table.concat({ parts[#parts - 1], parts[#parts] }, "/")
		elseif #parts == 1 then
			short = parts[1]
		end
	end
	return short or filename or ""
end

-- truncate long strings from the front with "~"
local function ellipsis_front(str, max_len)
	if not str or #str <= max_len then
		return str or ""
	end
	return "..." .. string.sub(str, -max_len + 3)
end

-- dynamically measure columns and build padded display
return function(symbols)
	local col_width = 60
	local max_kind, max_name, max_file = 0, 0, 0
	for _, sym in ipairs(symbols or {}) do
		local kindname = LSP_KIND[sym.kind or 0] or tostring(sym.kind or "")
		local name = sym.name or "<unnamed>"
		local uri = shorten_filename((sym.location and sym.location.uri) or sym.uri or sym.targetUri)
		local file = uri or ""
		max_kind = math.max(max_kind, #kindname)
		max_name = math.max(max_name, #name)
		max_file = math.max(max_file, #file)
	end

	-- constrain column width to at most 20 chars
	max_kind = math.min(max_kind, col_width)
	max_name = math.min(max_name, col_width)
	max_file = math.min(max_file, col_width)

	return function(sym)
		local uri, range = nil, nil
		if sym.location then
			uri, range = sym.location.uri, sym.location.range
		elseif sym.uri or sym.targetUri then
			uri = sym.uri or sym.targetUri
			range = sym.range or sym.targetRange
		end

		local filename = uri or ""
		local short = shorten_filename(filename)
		local start = (range and range.start) or { line = 0, character = 0 }
		local lnum = (start.line or 0) + 1
		local col = (start.character or 0) + 1

		local kindname = LSP_KIND[sym.kind or 0] or tostring(sym.kind or "")
		local name = sym.name or "<unnamed>"

		-- apply ellipsis if any field is longer than col_width chars
		kindname = ellipsis_front(kindname, col_width)
		name = ellipsis_front(name, col_width)
		short = ellipsis_front(short, col_width)

		return {
			value = sym,
			ordinal = table.concat({ kindname, name, short }, " "),
			display = string.format(
				-- "%d:%-" .. max_file .. "s %-" .. max_name .. "s %-" .. max_kind .. "s",
				"%-"
					.. max_file
					.. "s %-"
					.. max_name
					.. "s %-"
					.. max_kind
					.. "s",
				-- lnum,
				short,
				name,
				kindname
			),
			filename = filename,
			lnum = lnum,
			col = col,
			kind = kindname,
			name = name,
		}
	end
end
