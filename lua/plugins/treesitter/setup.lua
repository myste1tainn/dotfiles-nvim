 require("nvim-treesitter.configs").setup {
   ensure_installed = { "go", "python", "dart", "lua", "javascript" },
   highlight = {
     enable = true,
   },
   indent = {
     enable = true,
   },
 }
