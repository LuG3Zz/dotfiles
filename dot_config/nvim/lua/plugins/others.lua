return {
  {

    "kawre/leetcode.nvim",
    build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
      "nvim-telescope/telescope.nvim",
      -- "ibhagwan/fzf-lua",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      -- configuration goes here
      lang = "cpp",
      cn = { -- leetcode.cn
        enabled = true,
      },
      image_support = true,
    },
  },
  {
    {
      "3rd/image.nvim",
      opts = {},
    },
  },
  {
    "mg979/vim-visual-multi",
  },
  {
    "eandrju/cellular-automaton.nvim",
  },
}
