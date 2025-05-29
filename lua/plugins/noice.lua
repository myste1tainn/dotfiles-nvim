return {
  "folke/noice.nvim",
  config = function()
    require('noice').setup {
      -- Add your configuration here
    }
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  }
}
