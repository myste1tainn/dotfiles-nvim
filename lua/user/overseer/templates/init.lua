return vim.iter({
	require("user.overseer.templates.go"),
	require("user.overseer.templates.dart"),
})
	:flatten()
	:totable()
