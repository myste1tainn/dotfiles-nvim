return {
  "NeogitOrg/neogit",
  config = function()
    require('neogit').setup {}
  end,
  dependencies = {
    "sindrets/diffview.nvim"
  }
}
