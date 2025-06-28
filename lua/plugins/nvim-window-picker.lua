-- TODO: I might want to set this up properly i.e. neo-tree chooses the window to open by default
--       This will solve the problem where neo-tree / trobule / telescope would open the window in the last buffer active
--       But probably will have to find a way to integrate them (i.e. maybe there's "global" setup in nvim for when the buf is going to be opened, use this plugin first)
return {
	"s1n7ax/nvim-window-picker",
	name = "window-picker",
	event = "VeryLazy",
	version = "2.*",
	config = function()
		require("window-picker").setup()
	end,
}
