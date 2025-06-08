return {
	"ibhagwan/fzf-lua",
	config = function()
		require("fzf-lua").setup({
			git = {
				-- NOTE: This needs `brew install git-delta` on macOS
				preview_pager = "delta --paging=never",
			},
		})
	end,
}
