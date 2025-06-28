return {
	"nvim-lualine/lualine.nvim",
	config = function()
		local function recording()
			local reg = vim.fn.reg_recording()
			if reg == "" then
				return ""
			end
			return "Recording @" .. reg
		end
		require("lualine").setup({
			options = {
				-- theme = 'gruvbox',
				section_separators = "|",
				component_separators = "",
				globalstatus = true, -- Show global statusline
			},
			sections = {
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
					recording,
				},
			},
		})
	end,
}
