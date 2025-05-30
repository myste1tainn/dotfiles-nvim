return function(bufnr)
	require("core.keymaps.core.file_saving")(bufnr)
	require("core.keymaps.core.quickfix")(bufnr)
	require("core.keymaps.core.movement")(bufnr)
	require("core.keymaps.core.panes")(bufnr)
end
