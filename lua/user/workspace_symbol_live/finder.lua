local M = {}

function M.search(opts)
	opts = opts or {}
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local sorter = conf.generic_sorter(opts)
	local entry_maker = require("user.workspace_symbol_live.entry_maker")

	local src_bufnr = vim.api.nvim_get_current_buf() -- capture BEFORE picker:find()
	local picker

	local uv = vim.loop
	local timer = uv.new_timer()
	-- top-level locals inside M.search
	local last_issued = "" -- last query we sent
	local last_rendered = "" -- last query we rendered
	local in_flight = false
	local pending = nil
	local debounce_ms = opts.debounce_ms or 200

	local function issue(query)
		in_flight = true
		last_issued = query
		vim.lsp.buf_request_all(src_bufnr, "workspace/symbol", { query = query }, function(res_tbl)
			local all = {}
			for _, pack in pairs(res_tbl or {}) do
				local res = pack and pack.result or {}
				if type(res) == "table" then
					for _, s in ipairs(res) do
						if s.location and s.location.uri then
							s.location.uri = vim.uri_to_fname(s.location.uri)
						end
						-- if the uri is not of the current cwd, then filter ignore it
						if vim.startswith(s.location.uri, vim.loop.cwd()) then
							all[#all + 1] = s
						end
					end
				end
			end
			-- render
			picker:refresh(
				require("telescope.finders").new_table({ results = all, entry_maker = entry_maker(all) }),
				{ reset_prompt = false }
			)
			last_rendered = query
			in_flight = false

			-- if something new arrived while we were in flight, run it now
			if pending and pending ~= last_rendered then
				local q = pending
				pending = nil
				issue(q)
			end
		end)
	end
	picker = pickers.new(opts, {
		prompt_title = "Workspace Symbols (live)",
		finder = finders.new_table({ results = {}, entry_maker = entry_maker({}) }),
		sorter = sorter,
		previewer = conf.qflist_previewer(opts),
		layout_strategy = "vertical",
		layout_config = {
			prompt_position = "top",
			mirror = true, -- moves preview to bottom
			height = 0.9,
			preview_height = 0.4,
		},
		on_input_filter_cb = function(prompt)
			-- always return the prompt so Telescope keeps it
			local ret = { prompt = prompt }

			-- normalize
			prompt = prompt or ""
			if prompt == "" then
				-- Optional: clear results on empty prompt
				picker:refresh(
					require("telescope.finders").new_table({ results = {}, entry_maker = entry_maker({}) }),
					{ reset_prompt = false }
				)
				return ret
			end

			-- coalesce identical queries
			if prompt == last_issued or prompt == last_rendered then
				return ret
			end

			-- debounce typing
			pending = prompt
			timer:stop()
			timer:start(debounce_ms, 0, function()
				vim.schedule(function()
					-- if a request is running, leave `pending` set; it will run right after
					if in_flight then
						return
					end
					if pending and pending ~= last_issued then
						local q = pending
						pending = nil
						issue(q)
					end
				end)
			end)

			return ret
		end,
	})

	picker:find()

	local prompt_bufnr = picker.prompt_bufnr
	vim.api.nvim_create_autocmd("WinClosed", {
		once = true,
		callback = function()
			if timer:is_active() then
				timer:stop()
			end
			timer:close()
		end,
		buffer = prompt_bufnr,
	})
end

return M
