local finder = require("user.workspace_symbol_live.finder")
vim.api.nvim_create_user_command("WorkspaceSymbolSearch", function()
	finder.search({
		debounce_ms = 180,
		layout_config = { width = 0.95, height = 0.90 },
	})
end, {})
return finder
