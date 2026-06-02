-- Setup for overseer.nvim
return {
	{
		"stevearc/overseer.nvim",
		cmd = { "OverseerRun", "OverseerToggle", "OverseerOpen", "OverseerClose", "OverseerTaskAction" },
		config = function()
			-- refer to this https://github.com/stevearc/overseer.nvim/blob/master/doc/reference.md#parameters
			-- TODO: CHeck why this "overseer" instance is mapped to "core.keymaps.overseer", when it should have been
			-- overseer module, this indicates that there's something wrong within lua_ls setup
			local overseer = require("overseer")
			overseer.setup({
				default_strategy = "jobstart",
				template_timeout = 5000, -- Timeout for template loading
				task_list = {
					bindings = {
						["<C-q>"] = "Close",
						["<C-c>"] = false,
					},
				},
			})
			-- -- Register once at start-up
			-- overseer.register_component("tail_quickfix", function(params)
			-- 	-- merge user params with our defaults
			-- 	params = vim.tbl_extend("force", {
			-- 		tail = true, -- stream incrementally
			-- 		items_only = true, -- ignore non-matching lines
			-- 	}, params or {})
			--
			-- 	-- reuse the stock quickfix component
			-- 	local base = require("overseer.component.on_output_quickfix").constructor(params)
			--
			-- 	-- kill the expensive full-buffer rebuild
			-- 	base.on_pre_result = function() end
			-- 	return base
			-- end)
			local prebuilt_templates = require("user.overseer.templates")

			for _, template in pairs(prebuilt_templates) do
				overseer.register_template(template)
			end

			-- Wrap build_task_args to record history after the user confirms params.
			-- This is the real chokepoint: every template run (interactive or programmatic)
			-- passes through here with the final resolved params.
			local tmpl_mod = require("overseer.template")
			local orig_build = tmpl_mod.build_task_args
			tmpl_mod.build_task_args = function(tmpl, opts, callback)
				orig_build(tmpl, opts, function(err, task_defn, params)
					if
						not err
						and task_defn
						and tmpl
						and tmpl.name
						and not vim.startswith(tostring(tmpl.name), "History #")
					then
						require("user.overseer.history").add(tmpl.name, params or {})
					end
					callback(err, task_defn, params)
				end)
			end

			-- Format resolved params into a short readable string for the history display name.
			local function format_history_params(params)
				if not params or vim.tbl_isempty(params) then
					return nil
				end
				local visible = {}
				for k, v in pairs(params) do
					if not vim.startswith(tostring(k), "_") then
						table.insert(visible, { k = k, v = v })
					end
				end
				if #visible == 0 then
					return nil
				end
				table.sort(visible, function(a, b)
					return a.k < b.k
				end)
				-- Single string param: show value only (e.g. Shell cmd)
				if #visible == 1 and type(visible[1].v) == "string" and visible[1].v ~= "" then
					return visible[1].v
				end
				local parts = {}
				for _, entry in ipairs(visible) do
					local v = entry.v
					if type(v) == "string" and v ~= "" then
						table.insert(parts, entry.k .. "=" .. v)
					elseif type(v) == "number" then
						table.insert(parts, entry.k .. "=" .. tostring(v))
					elseif type(v) == "table" and #v > 0 then
						local items = {}
						for _, item in ipairs(v) do
							table.insert(items, tostring(item))
						end
						table.insert(parts, entry.k .. "=[" .. table.concat(items, ",") .. "]")
					end
				end
				return #parts > 0 and table.concat(parts, ", ") or nil
			end

			-- Dynamic generator: re-read history each time :OverseerRun opens.
			overseer.register_template({
				name = "history_generator",
				generator = function(_, cb)
					local history = require("user.overseer.history").get()
					local all_tmpls = require("user.overseer.templates")

					local result = {}
					for i, item in ipairs(history) do
						local orig_tmpl = nil
						for _, t in ipairs(all_tmpls) do
							if t.name == item.name then
								orig_tmpl = t
								break
							end
						end

						if orig_tmpl then
							local params_str = format_history_params(item.params)
							local display_name = params_str
									and string.format("History #%d - %s - %s", i, item.name, params_str)
								or string.format("History #%d - %s", i, item.name)

							table.insert(result, {
								name = display_name,
								-- No params: replay silently with stored values, no dialog
								builder = function(_)
									require("user.overseer.history").add(item.name, item.params)
									return orig_tmpl.builder(item.params)
								end,
							})
						end
					end

					cb(result)
				end,
			})
		end,
	},
}
