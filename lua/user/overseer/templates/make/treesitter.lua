-- Tree-sitter backed Makefile parser. Produces the exact same shape as
-- parser.parse (text fallback):
--   { targets = { { name, make = {sorted}, env = {sorted} }, ... },
--     assignments = { NAME = { value, dynamic }, ... } }
--
-- The `make` grammar exposes `variable_reference` nodes (Make variables) and
-- `variable_assignment` nodes (defaults + operator) cleanly, and separates
-- function calls so $(shell ...) is never mistaken for a variable. It does NOT
-- expose shell env vars: $$VAR collapses into an `escape` node, so those are
-- recovered with parser.scan_env_refs over the recipe text.

local parser = require("user.overseer.templates.make.parser")

local M = {}

local function child_of_type(node, type_name)
	for child in node:iter_children() do
		if child:type() == type_name then
			return child
		end
	end
	return nil
end

local function word_texts(node, src)
	local names = {}
	if not node then
		return names
	end
	for child in node:iter_children() do
		if child:type() == "word" then
			table.insert(names, vim.treesitter.get_node_text(child, src))
		end
	end
	return names
end

---@return boolean
function M.available()
	return (pcall(vim.treesitter.get_string_parser, "", "make"))
end

---@param content string
---@return nil|{ targets: table[], assignments: table<string, { value: string, dynamic: boolean }> }
function M.parse(content)
	local ok, lang_parser = pcall(vim.treesitter.get_string_parser, content, "make")
	if not ok or not lang_parser then
		return nil
	end
	local trees = lang_parser:parse()
	local tree = trees and trees[1]
	if not tree then
		return nil
	end
	local root = tree:root()

	local var_query = vim.treesitter.query.parse("make", "(variable_reference (word) @name)")

	local assignments = {}
	local phony = {}
	local order = {}
	local by_name = {}

	local function get_or_create(name)
		local t = by_name[name]
		if not t then
			t = { name = name, make = {}, env = {}, has_recipe = false, has_prereqs = false }
			by_name[name] = t
			table.insert(order, t)
		end
		return t
	end

	-- Single document-order walk: collect assignments and rules.
	local function walk(node)
		for child in node:iter_children() do
			local t = child:type()
			if t == "variable_assignment" then
				local name_node = child_of_type(child, "word")
				if name_node then
					local name = vim.treesitter.get_node_text(name_node, content)
					local value_node = child_of_type(child, "text")
					local value = value_node and vim.treesitter.get_node_text(value_node, content) or ""
					assignments[name] = { value = value, dynamic = value:find("%$") ~= nil }
				end
			elseif t == "rule" then
				local targets_node = child_of_type(child, "targets")
				local prereq_node = child_of_type(child, "prerequisites")
				local recipe_node = child_of_type(child, "recipe")
				local target_names = word_texts(targets_node, content)
				local has_prereqs = #word_texts(prereq_node, content) > 0

				if target_names[1] == ".PHONY" or target_names[1] == ".phony" then
					for _, p in ipairs(word_texts(prereq_node, content)) do
						phony[p] = true
					end
				else
					-- Make variables referenced in the recipe (scoped to recipe node).
					local make_set = {}
					if recipe_node then
						for _, n in var_query:iter_captures(recipe_node, content) do
							make_set[vim.treesitter.get_node_text(n, content)] = true
						end
					end
					local env_set = {}
					if recipe_node then
						parser.scan_env_refs(vim.treesitter.get_node_text(recipe_node, content), env_set)
					end

					for _, tname in ipairs(target_names) do
						if parser.is_command_name(tname) then
							local entry = get_or_create(tname)
							if recipe_node then
								entry.has_recipe = true
							end
							if has_prereqs then
								entry.has_prereqs = true
							end
							for k in pairs(make_set) do
								entry.make[k] = true
							end
							for k in pairs(env_set) do
								entry.env[k] = true
							end
						end
					end
				end
			end
			-- Recurse so rules/assignments inside conditionals (ifeq/...) are found.
			walk(child)
		end
	end
	walk(root)

	local function set_to_sorted_list(set)
		local list = {}
		for k in pairs(set) do
			table.insert(list, k)
		end
		table.sort(list)
		return list
	end

	local targets = {}
	for _, t in ipairs(order) do
		if t.has_recipe or phony[t.name] or t.has_prereqs then
			table.insert(targets, {
				name = t.name,
				make = set_to_sorted_list(t.make),
				env = set_to_sorted_list(t.env),
			})
		end
	end

	return { targets = targets, assignments = assignments }
end

return M
