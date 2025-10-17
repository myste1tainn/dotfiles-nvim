local neotest = require("neotest")
local neotest_fns = require("user.neotest.functions")
local common = require("user.overseer.templates.dart.common")
local path_util = require("utils.path")

local uniq = function(acc, dir)
	if not acc._seen then
		acc._seen = {}
	end
	if not acc._seen[dir] then
		table.insert(acc, dir)
		acc._seen[dir] = true
	end
	return acc
end

local get_dir = function(file)
	return file:match("(.+)/") or file
end

return {
	name = "3. Test",
	condition = common.condition,
	params = function()
		local root, files = path_util.root_and_files_under_pattern("go.mod", "**/*_test.go")
		-- Before root changes, we want to convert files to relative paths (it has the last segment of the path)
		files = path_util.convert_to_relative_path(root)(files)
		-- Get all directories from files also, unique them
		local directories = vim.iter(files):map(get_dir):fold({}, uniq)
		files = vim.list_extend(files, directories)
		-- Merge directories and files into a single list
		root = path_util.convert_to_relative_path()(root)
		return {
			file = {
				type = "string",
				optional = true,
				default = "",
				choices = files,
				desc = "Test file / directory to run, empty for all tests",
			},
			root = { type = "string", default = root, desc = "Root directory for the Go project" },
			args = { type = "list", optional = true, default = {}, desc = "Arguments to pass to the program" },
		}
	end,
	builder = function(params)
		-- if file is empty, run all tests in the current directory
		local previous_root = vim.fn.getcwd()
		-- Change cwd to the root directory, then run neotest
		local root = vim.fn.getcwd() .. "/" .. params.root
		local neotest_args = "./" .. params.file
		local test_file = params.file
		if params.file == "" then
			if params.root == "" then
				neotest_args = "./"
			end
			test_file = "all tests"
		end
		vim.schedule(function()
			vim.cmd("cd " .. root)
			neotest.run.run(neotest_args)
			neotest_fns.open()
			vim.cmd("cd " .. previous_root)
		end)
		return {
			name = "Test " .. test_file .. " in " .. params.root,
			components = {
				"default",
				-- TODO: make this component common in go templates, along with cwd below
				{
					"on_output_quickfix",
					-- errorformat = "%f:%l%*[^:]", -- TODO: Error format seems to format stuffs also, and it's ugly, deal with it later
					-- Remove the default errorformat override and define your own:
					errorformat = table.concat({
						-- Match Go stacktrace lines (filename:line)
						"%f:%l: %m",
						-- Match shortened relative paths (e.g., pkg/foo.go|12|)
						"%f|%l| %m",
						-- Don't match timestamps like `2025/06/25 00:00:05` accidentally
					}, ","),
					open = true,
				},
			},
			cmd = { "true" },
			-- TODO: make this component common in go templates, along with component above
			cwd = params.root, -- NOTE: This may breaks later on, if params.root is not relative to the cwd anymore
		}
	end,
}
