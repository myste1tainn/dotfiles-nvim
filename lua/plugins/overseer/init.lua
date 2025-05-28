-- Setup for overseer.nvim
return {
  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup()
    end,
  },
}

