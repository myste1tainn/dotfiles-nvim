return vim.iter({
	require("user.overseer.templates.shell"),
	require("user.overseer.templates.go"),
	require("user.overseer.templates.dart"),
	require("user.overseer.templates.rust"),
	require("user.overseer.templates.podman"),
})
	:flatten()
	:totable()
