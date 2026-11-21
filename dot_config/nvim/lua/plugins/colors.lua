-- 主题：默认 gruvbox，可切 catppuccin（<leader>uC，持久化）

return {
  -- 禁用 LazyVim 默认的 tokyonight
  { "folke/tokyonight.nvim", enabled = false },

  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_mode = true,
      contrast = "soft",
      italic = { strings = false, comments = false },
      overrides = {},
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      no_italic = true,
      integrations = {
        treesitter = true,
        snacks = true,
        mini = true,
        blink_cmp = true,
      },
    },
  },

  -- 应用持久化主题：覆盖 LazyVim 的 colorscheme 函数（默认要求 tokyonight）
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("config.theme").apply(require("config.theme").saved())
      end,
    },
  },
}
