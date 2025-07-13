return function(bufnr)
	require("core.keymaps.core.file_saving")(bufnr)
	require("core.keymaps.core.quickfix")(bufnr)
	require("core.keymaps.core.movement")(bufnr)
	require("core.keymaps.core.panes")(bufnr)
	require("core.keymaps.core.buffers")(bufnr)
	require("core.keymaps.core.git")(bufnr)
end
