local template_name = "Shell: 0. Custom"

return {
	{
		name = template_name,
		params = function()
			return {
				cmd = {
					type = "string",
					name = "Command",
					desc = "Shell command to run",
					optional = false,
				},
			}
		end,
		builder = function(params)
			return {
				name = params.cmd,
				cmd = { "sh", "-c", params.cmd or "" },
				components = { "default" },
			}
		end,
	},
}
