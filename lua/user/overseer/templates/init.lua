return vim.iter({
	require("user.overseer.templates.go"),
})
	:flatten()
	:totable()
