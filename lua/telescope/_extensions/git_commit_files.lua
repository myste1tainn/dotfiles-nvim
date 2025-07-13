-- lua/telescope/_extensions/git_commit_files.lua
local tmp_dirs = {} -- Keep track of extracted commit dirs

local function extract_commit_to_tmp(commit)
	if tmp_dirs[commit] then
		return tmp_dirs[commit]
	end

	local tmpdir = vim.fn.tempname()
	vim.fn.mkdir(tmpdir, "p")

	-- Extract commit contents to temp dir
	local cmd = string.format("git archive %s | tar -x -C %s", commit, tmpdir)
	local result = os.execute(cmd)
	if result ~= 0 then
		vim.notify("Failed to extract commit " .. commit, vim.log.levels.ERROR)
		return nil
	end

	tmp_dirs[commit] = tmpdir
	return tmpdir
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local search_mode = "files" -- Can be "files" or "grep"

M.git_files_at_commit = function(commit)
	local tmpdir = extract_commit_to_tmp(commit)
	if not tmpdir then
		return
	end

	if search_mode == "files" then
		-- File list mode
		local output = vim.fn.systemlist({ "git", "ls-tree", "-r", "--name-only", commit })
		if vim.v.shell_error ~= 0 then
			vim.notify("Failed to list files for commit " .. commit, vim.log.levels.ERROR)
			return
		end

		pickers
			.new({}, {
				prompt_title = "Files at " .. commit,
				finder = finders.new_table({
					results = output,
				}),
				sorter = conf.generic_sorter(),
				previewer = previewers.new_buffer_previewer({
					define_preview = function(self, entry, _)
						local cmd = { "git", "show", commit .. ":" .. entry.value }
						local content = vim.fn.systemlist(cmd)
						if vim.v.shell_error ~= 0 then
							content = { "Failed to load file content" }
						end
						vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)
						local filetype = vim.filetype.match({ filename = entry.value }) or "text"
						vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", filetype)
					end,
				}),
				attach_mappings = function(prompt_bufnr, map)
					local function open_file(mode)
						local entry = action_state.get_selected_entry()
						actions.close(prompt_bufnr)

						local path = entry.value
						local tmpfile = vim.fn.tempname()
						local content = vim.fn.systemlist({ "git", "show", commit .. ":" .. path })
						vim.fn.writefile(content, tmpfile)

						local open_cmd = (mode == "vsplit") and "vert edit" or "edit"
						vim.cmd(open_cmd .. " " .. tmpfile)
						vim.cmd("doautocmd BufReadPost " .. tmpfile)
					end

					map("i", "<CR>", function()
						open_file("edit")
					end)
					map("i", "<C-v>", function()
						open_file("vsplit")
					end)
					map("i", "<C-f>", function()
						actions.close(prompt_bufnr)
						search_mode = "grep"
						M.git_files_at_commit(commit)
					end)

					return true
				end,
			})
			:find()
	else
		-- Grep mode
		require("telescope.builtin").live_grep({
			prompt_title = "Grep in " .. commit,
			cwd = tmpdir,
			attach_mappings = function(_, map)
				map("i", "<C-f>", function()
					search_mode = "files"
					M.git_files_at_commit(commit)
				end)
				return true
			end,
		})
	end
end

return M
