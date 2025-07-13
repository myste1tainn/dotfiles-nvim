local M = {}

-- Filetypes that is not considered a "real" buffer, like Neogit, quickfix, help, etc.
M.special_wins = {
	"NeogitStatus",
	"NeogitPopup",
	"NeogitCommitMessage",
	"qf", -- quickfix
	"help",
	"lazy", -- lazy.nvim UI
	"TelescopePrompt",
	"neo-tree",
	"neotest-summary",
	"neotest-output",
	"neotest-output-panel",
	"neogitstatus",
	"neogitpopup",
	"neogitcommitmessage",
	"AvanteInput", -- add any others
	"AvanteSelectedFiles", -- add any others
	"Avante",
}

M.excluded_buftypes = {
	"nofile",
	"prompt",
	"popup",
	"terminal",
	"quickfix",
	"help",
}

local keep_filetypes = {}
for _, ft in ipairs(M.special_wins) do
	keep_filetypes[ft] = true
end

M.keep_filetypes = keep_filetypes

return M
