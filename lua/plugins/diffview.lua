return {
	"sindrets/diffview.nvim",
	opts = {
		enchanced_diff_hl = true,
		view = {
			default = {
				layout = "diff2_horizontal",
				winbar_info = true,
			},
			merge_tool = {
				layout = "diff4_mixed",
				winbar_info = true,
			},
			file_history = {
				layout = "diff2_horizontal",
				winbar_info = true,
			},
		},
	},
}
