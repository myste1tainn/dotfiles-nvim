-- TODO: There are some keys that you can map to manipulate the size of buffers, I might want to set that up later
return {
	"kwkarlwang/bufresize.nvim",
	config = function()
		require("bufresize").setup()
	end,
}
