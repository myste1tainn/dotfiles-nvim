-- Setup for gruvbox.nvim
return {
  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      -- Set the colorscheme to gruvbox
      vim.cmd([[colorscheme gruvbox]])
    end,
  },
}

