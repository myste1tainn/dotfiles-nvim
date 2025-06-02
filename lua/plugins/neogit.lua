return {
	"NeogitOrg/neogit",
	config = function()
		require("neogit").setup({
			disable_signs = false,
			disable_context_highlighting = false,
			disable_commit_confirmation = true,
			kind = "tab",
			signs = {
				section = { ">", "v" },
				item = { ">", "v" },
				hunk = { "", "" },
			},
			mappings = {
				status = {
					["<cr>"] = "Toggle",
					["<space>"] = "TabOpen",
					["<tab>"] = "NextSection",
					["<s-tab>"] = "PreviousSection",
					["j"] = "MoveDown",
					["k"] = "MoveUp",
					["<up>"] = "PeekUp",
					["<down>"] = "PeekDown",
				},
			},
			integrations = {
				diffview = true,
			},
		})
	end,
	dependencies = {
		"sindrets/diffview.nvim",
	},
}
