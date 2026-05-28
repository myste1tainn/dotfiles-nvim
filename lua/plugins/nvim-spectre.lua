return {
	"nvim-pack/nvim-spectre",
	cmd = "Spectre",
	keys = { { "<leader>sp", ":lua require('spectre').toggle()<CR>", desc = "Toggle Spectre" } },
	build = 'SDKROOT="$(xcrun --show-sdk-path)" bash',
	config = function()
		require("spectre").setup({
			default = {
				replace = {
					cmd = "oxi",
				},
			},
			-- replace_engine = {
			-- 	["sed"] = {
			-- 		cmd = "gsed",
			-- 		args = nil,
			-- 		options = {
			-- 			["ignore-case"] = {
			-- 				value = "--ignore-case",
			-- 				icon = "[I]",
			-- 				desc = "ignore case",
			-- 			},
			-- 		},
			-- 		warn = true,
			-- 	},
			-- },
		})
	end,
}
