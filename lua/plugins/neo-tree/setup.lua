require("neo-tree").setup({
  window = { position = "left", width = 30 },
  buffers = { follow_current_file = { enabled = true } },
  filesystem = {
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = true,
    },
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },
  default_component_configs = {
    diagnostics = {
      symbols = {
        hint = "",
        info = "",
        warn = "",
        error = "",
      },
    },
  },
})
