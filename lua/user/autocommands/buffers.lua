local wins = require("utils.wins")

--- This will keeps these buffer with filetypes out of the buffer list
vim.api.nvim_create_autocmd("FileType", {
	pattern = wins.special_wins,
	callback = function()
		vim.bo.buflisted = false
	end,
})
