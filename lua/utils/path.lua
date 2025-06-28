local util = require("lspconfig.util")
local M = {}

function M.get_root_with_pattern(root_pattern)
	-- 1. Try LSP root for current buffer
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	-- local clients = vim.lsp.get_active_clients({ bufnr = bufnr })

	for _, client in ipairs(clients) do
		local workspace = client.config.root_dir
		if workspace then
			return workspace
		end
	end

	-- 2. Fallback to go.mod search from current file
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	local mod_root = util.root_pattern(root_pattern)(filepath)
	if mod_root then
		return mod_root
	end

	-- 3. Fallback to cwd
	return vim.fn.getcwd()
end

function M.root_and_files_under_pattern(root_pattern, file_type)
	local root = M.get_root_with_pattern(root_pattern)
	local glob_pattern = "**/*." .. file_type
	if file_type:find("%*") then
		-- if file_type contains "*", means it's a glob pattern, use it directly
		glob_pattern = file_type
	end
	local files = vim.fn.globpath(root, glob_pattern, false, true)
	return root, files
end

--- Converts an absolute path to a relative path based on the current working directory.
--- @generic T: string | string[]
--- @param prefix? string Optional absolute base path to remove; defaults to current working directory.
--- @return fun(object: T): T
function M.convert_to_relative_path(prefix)
	return function(object)
		local final_prefix = prefix or vim.fn.getcwd()
		local function remove_preifx(path)
			if path:sub(1, #final_prefix) == final_prefix then
				local p = path:sub(#final_prefix + 1) -- +1 to remove the trailing slash
				if p == "" then
					return "." -- Return current directory if the path is just the prefix
				end
				return path:sub(#final_prefix + 2) -- +2 to remove the trailing slash
			else
				return path -- Return as is if not under prefix
			end
		end
		-- Convert an absolute path to a relative path based on the current working directory
		if type(object) == "string" then
			return remove_preifx(object)
		end

		-- Check if the object is a table of strings
		if type(object) == "table" and vim.islist(object) then
			return vim.tbl_map(remove_preifx, object)
		end

		error("Invalid path type: " .. type(object) .. ". Expected string or table of strings.")
	end
end

function M.run_in_root_with_pattern(root_pattern, fn)
	-- Change the current working directory to the root directory found by the pattern
	local root = M.get_root_with_pattern(root_pattern)
	local previous_root = vim.fn.getcwd()
	vim.cmd("cd " .. root) -- Change directory to the root of the Go project
	fn()
	vim.cmd("cd " .. previous_root) -- Change back to the previous directory
end

return M
