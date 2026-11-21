-- treesitter：在 LazyVim 默认语言基础上补齐个人用到的语言

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, {
        "bash",
        "c",
        "cpp",
        "csv",
        "gotmpl", -- chezmoi 模板
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "r",
        "rnoweb",
        "rust",
      })
    end,
  },
}
