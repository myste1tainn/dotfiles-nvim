#!/bin/bash

NVIM_DIR="$HOME/.config/nvim"
mkdir -p "$NVIM_DIR/lua/plugins/lang"
mkdir -p "$NVIM_DIR/lua/core"

echo "[+] Creating init.lua"
cat > "$NVIM_DIR/init.lua" << 'EOF'
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

require("core.options")
require("core.keymaps")
EOF

echo "[+] Creating plugins/init.lua"
cat > "$NVIM_DIR/lua/plugins/init.lua" << 'EOF'
return {
  { import = "plugins.avante" },
}
EOF

echo "[+] Creating plugins/avante.lua"
cat > "$NVIM_DIR/lua/plugins/avante.lua" << 'EOF'
return {
  "yetone/avante.nvim",
  build = "make",
  event = "VeryLazy",
  version = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "markdown", "Avante" } },
      ft = { "markdown", "Avante" },
    },
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true,
        },
      },
    },
  },
  opts = {
    provider = "openai",
    auto_suggestions_provider = "openai",
    openai = {
      api_key = os.getenv("OPENAI_API_KEY"),
      model = "gpt-4o",
    },
  },
}
EOF

echo "[+] Creating core/options.lua"
cat > "$NVIM_DIR/lua/core/options.lua" << 'EOF'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
EOF

echo "[+] Creating core/keymaps.lua"
cat > "$NVIM_DIR/lua/core/keymaps.lua" << 'EOF'
local keymap = vim.keymap.set

-- Avante AI commands
keymap("n", "<leader>ac", ":AvanteChat<CR>")
keymap("v", "<leader>ae", ":AvanteEdit<CR>")
keymap("n", "<leader>af", ":AvanteFiles<CR>")
EOF

for lang in python js go flutter; do
  echo "[+] Creating plugins/lang/${lang}.lua"
  cat > "$NVIM_DIR/lua/plugins/lang/${lang}.lua" <<EOF
-- Placeholder for ${lang} LSP, formatter, test, etc.
return {}
EOF
done

echo "[✓] All files generated. Launch Neovim and run :Lazy sync"

