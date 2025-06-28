return {
	name = "Load-test: k6 local",
	builder = function(params)
		return {
			cmd = { "k6" },
			args = { "run", "--summary-export=summary.json", params.script },
			env = { K6_NO_UPDATE_CHECK = "1" },
			components = {
				{ "on_output_quickfix", open = true, errorformat = "%f:%l %m" },
				{ "default" },
			},
		}
	end,
	condition = {
		filetype = { "javascript", "typescript", "k6" },
	},
}
