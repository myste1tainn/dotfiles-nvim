return {
	"NeogitOrg/neogit",
	dependencies = {
		require("plugins.diffview"),
	},
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
					["y"] = false,
					["<C-p>"] = "ShowRefs", -- TODO: <C-y> is conflicting to file_saving.lua keymaps
				},
				popup = {
					["l"] = false,
					["<C-l>"] = "LogPopup",
					-- NOTE: "h" doesn't have conflicting map
					["b"] = false,
					["<C-b>"] = "BranchPopup",
					["w"] = false,
					["<C-w>"] = "WorktreePopup",
					["v"] = false,
					["<C-v>"] = "RevertPopup",
					["f"] = false,
					["<C-f>"] = "FetchPopup",
					-- ["c"] = false,
					-- ["<C-c>"] = "CommitPopup",
				},
			},
			integrations = {
				diffview = true,
			},
		})
	end,
}
