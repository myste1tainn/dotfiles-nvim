return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers",
				-- numbers = "both",
				numbers = "ordinal",
				close_command = "bdelete! %d",
				right_mouse_command = "bdelete! %d",
				left_mouse_command = "buffer %d",
				middle_mouse_command = nil,
				indicator_icon = "▎",
				buffer_close_icon = "",
				modified_icon = "●",
				close_icon = "",
				show_close_icon = true,
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_tab_indicators = true,
				enforce_regular_tabs = true,
				always_show_bufferline = true,
			},
		})
	end,
}
