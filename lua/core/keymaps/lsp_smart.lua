-- lua/lsp_smart.lua
local M = {}

-- ignore non-intel clients
local IGNORE = { copilot = true, ["null-ls"] = true, eslint = true }
-- Pick a sane offset encoding from a real LSP (ignore Copilot/null-ls)
local function pick_offset_encoding(bufnr, method)
	for _, c in ipairs(vim.lsp.get_clients({ buffer = bufnr or 0 })) do
		if not IGNORE[c.name] and (not method or (c.supports_method and c.supports_method(method))) then
			return c.offset_encoding or c.server_capabilities and c.server_capabilities.offsetEncoding or "utf-16"
		end
	end
	return "utf-16" -- fallback (Neovim’s default expectation)
end

local function clients_supporting(method, bufnr)
	local out = {}
	for _, c in ipairs(vim.lsp.get_clients({ buffer = bufnr or 0 })) do
		if not IGNORE[c.name] and c.supports_method and c.supports_method(method) then
			table.insert(out, c)
		end
	end
	return out
end

function M.request_all(method, params, cb, bufnr)
	bufnr = bufnr or 0
	local cs = clients_supporting(method, bufnr)
	if #cs == 0 then
		return cb({})
	end
	vim.lsp.buf_request_all(bufnr, method, params, function(resps)
		cb(resps or {})
	end)
end

----------------------------------------------------------------------
-- 🔧 Normalizers: SymbolInformation/WorkspaceSymbol/LocationLink → Location
----------------------------------------------------------------------

-- Turn mixed results (SymbolInformation | WorkspaceSymbol | Location | LocationLink)
-- into a flat list of *Location* objects { uri = ..., range = ... }.
local function to_locations(result_any)
	local out = {}

	local function push_loc(loc)
		if not loc then
			return
		end
		-- LocationLink -> Location
		if loc.targetUri and loc.targetRange then
			table.insert(out, { uri = loc.targetUri, range = loc.targetRange })
			return
		end
		-- Location
		if loc.uri and loc.range then
			table.insert(out, { uri = loc.uri, range = loc.range })
		end
	end

	-- Single object
	if result_any and not vim.islist(result_any) then
		if result_any.location then -- SymbolInformation / WorkspaceSymbol
			push_loc(result_any.location)
			return out
		end
		push_loc(result_any) -- Location or LocationLink directly
		return out
	end

	-- List
	for _, v in ipairs(result_any or {}) do
		if v then
			if v.location then -- SymbolInformation / WorkspaceSymbol
				push_loc(v.location)
			else
				push_loc(v) -- Location or LocationLink
			end
		end
	end
	return out
end

-- Merge all LSP responses into a flat list of *Locations*
function M.responses_to_locations(responses)
	local locs = {}
	for _, resp in pairs(responses or {}) do
		local r = resp.result
		if r then
			vim.list_extend(locs, to_locations(r))
		end
	end
	return locs
end

-- Convert Locations -> quickfix items safely
function M.locations_to_items(locs, bufnr)
	bufnr = bufnr or 0
	if not locs or #locs == 0 then
		return {}
	end
	return vim.lsp.util.locations_to_items(locs, bufnr)
end

----------------------------------------------------------------------
-- 📚 Build a "catalog" by querying many broad tokens and merging
-- opts.max: cap total unique items (default 3000)
-- opts.tokens: override query tokens
----------------------------------------------------------------------

-- Resolve WorkspaceSymbol entries that have no location
-- Limits the number of resolves to avoid spamming the server.
local function resolve_workspace_symbols(symbols, max_resolves, done)
	max_resolves = max_resolves or 200
	local to_resolve = {}
	for _, s in ipairs(symbols or {}) do
		if s and not s.location then
			table.insert(to_resolve, s)
			if #to_resolve >= max_resolves then
				break
			end
		end
	end
	if #to_resolve == 0 then
		return done(symbols)
	end

	local remaining = #to_resolve
	for _, s in ipairs(to_resolve) do
		vim.lsp.buf_request_all(0, "workspace/symbol/resolve", s, function(resps)
			-- resps is a table keyed by client_id; grab first result with a location
			for _, r in pairs(resps or {}) do
				if r and r.result and r.result.location then
					-- mutate the original symbol so later normalization sees a location
					s.location = r.result.location
					break
				end
			end
			remaining = remaining - 1
			if remaining == 0 then
				done(symbols)
			end
		end)
	end
end

function M.workspace_symbols_catalog(opts, cb)
	opts = opts or {}
	local max = opts.max or 3000
	-- small, high-yield seeds; tweak to taste
	local tokens = opts.tokens
		or {
			"a",
			"e",
			"i",
			"o",
			"u",
			"ma",
			"re",
			"in",
			"er",
			"on",
			"get",
			"set",
			"new",
			"ctx",
			"req",
			"res",
			"http",
			"db",
			"id",
			"log",
			"err",
		}

	local seen_qf, acc_qf = {}, {}

	local function dedupe_and_add(items)
		for _, it in ipairs(items or {}) do
			local key =
				string.format("%s:%d:%d:%s", it.filename or it.uri or "", it.lnum or 0, it.col or 0, it.text or "")
			if not seen_qf[key] then
				seen_qf[key] = true
				table.insert(acc_qf, it)
				if #acc_qf >= max then
					return true
				end
			end
		end
		return false
	end

	-- resolve WorkspaceSymbols (no location) -> add location via workspace/symbol/resolve
	local function resolve_missing_locations(symbols, max_resolves, done)
		max_resolves = max_resolves or 200
		local to_resolve = {}
		for _, s in ipairs(symbols or {}) do
			if s and not s.location then
				table.insert(to_resolve, s)
				if #to_resolve >= max_resolves then
					break
				end
			end
		end
		if #to_resolve == 0 then
			return done(symbols)
		end

		local remaining = #to_resolve
		for _, s in ipairs(to_resolve) do
			vim.lsp.buf_request_all(0, "workspace/symbol/resolve", s, function(resps)
				for _, r in pairs(resps or {}) do
					if r and r.result and r.result.location then
						s.location = r.result.location
						break
					end
				end
				remaining = remaining - 1
				if remaining == 0 then
					done(symbols)
				end
			end)
		end
	end

	local i = 1
	local function step()
		if i > #tokens or #acc_qf >= max then
			return cb(acc_qf)
		end
		local q = tokens[i]
		i = i + 1

		-- 1) ask ALL real LSPs for workspace symbols
		M.request_all("workspace/symbol", { query = q }, function(resps)
			-- 2) flatten raw results to symbol arrays (don’t convert to Locations here)
			local symbols = {}
			for _, resp in pairs(resps or {}) do
				local r = resp and resp.result
				if r then
					if vim.islist(r) then
						vim.list_extend(symbols, r)
					else
						table.insert(symbols, r)
					end
				end
			end

			-- 3) resolve WorkspaceSymbols that don't have .location
			resolve_missing_locations(symbols, 150, function(resolved)
				-- NEW:
				local enc = pick_offset_encoding(0, "workspace/symbol")
				local items = vim.lsp.util.symbols_to_items(resolved, 0, enc) or {}

				local done = dedupe_and_add(items)
				if done then
					cb(acc_qf)
				else
					vim.schedule(step)
				end
			end)
		end, 0)
	end

	step()
end

return M
