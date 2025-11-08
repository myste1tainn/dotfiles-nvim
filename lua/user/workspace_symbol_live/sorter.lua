-- File: lua/workspace_symbol_sort.lua
local M = {}

local function symbol_name(entry)
	return entry.symbol_name
		or entry.name
		or (entry.value and (entry.value.symbol_name or entry.value.name))
		or entry.ordinal
		or ""
end

local function boundary_find(s, q, case_sensitive)
	if not case_sensitive then
		s, q = s:lower(), q:lower()
	end
	local pat = "%f[%w]" .. vim.pesc(q) .. "%f[%w]"
	return s:find(pat)
end

function M.exact_contains_sorter()
	local sorters = require("telescope.sorters")
	local fallback = require("telescope.config").values.generic_sorter({})

	return sorters.Sorter:new({
		scoring_function = function(_, prompt, entry)
			if not prompt or prompt == "" then
				-- Defer to fallback when nothing typed
				return fallback:score(prompt, entry)
			end

			local name = symbol_name(entry)
			if name == "" then
				return fallback:score(prompt, entry)
			end

			-- Tier 1: exact word-boundary matches
			local pos_cs = boundary_find(name, prompt, true)
			if pos_cs then
				-- better if earlier and shorter name
				return 0 + (pos_cs / 1000) + (#name / 1e6)
			end

			local pos_ci = boundary_find(name, prompt, false)
			if pos_ci then
				return 10 + (pos_ci / 1000) + (#name / 1e6)
			end

			-- Tier 2: plain contains
			local pos_cont_cs = name:find(prompt, 1, true)
			if pos_cont_cs then
				return 20 + (pos_cont_cs / 1000) + (#name / 1e6)
			end

			local pos_cont_ci = name:lower():find(prompt:lower(), 1, true)
			if pos_cont_ci then
				return 30 + (pos_cont_ci / 1000) + (#name / 1e6)
			end

			-- Fallback to Telescope fuzzy so non-matches still sort reasonably
			return 100 + (fallback:score(prompt, entry) or 1e9)
		end,

		-- optional: we can keep Telescope’s default highlighter
		highlighter = function()
			return {}
		end,
	})
end

return M
