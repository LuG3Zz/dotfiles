-- LSP 服务器：沿用原配置的四个服务器及其设置
-- clangd 通过 cmd 加 --completion-style=bundled（补全返回体小、响应快）；
-- clangd 在 mason 的 bin 目录里，LazyVim 已将其前置到 PATH。

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      servers = {
        clangd = {
          cmd = { "clangd", "--completion-style=bundled" },
        },
        pyright = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = true,
              check = { command = "clippy" },
              procMacro = { enable = true },
              inlayHints = {
                bindingModeHints = { enable = true },
                typeHints = { enable = true },
                parameterHints = { enable = true },
                closingBraceHints = { enable = true },
                lifetimeElisionHints = { enable = true, useParameterNames = true },
                closureCaptureHints = { enable = true },
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              hint = {
                enable = true,
                setType = true,
                paramType = true,
                paramName = "All",
              },
            },
          },
        },
      },
    },
  },

  -- C/C++/Rust 格式化走 LSP 内建（clangd/rust-analyzer 内嵌 clang-format/rustfmt，
  -- 无需 conform 另装二进制；覆盖 LazyVim 默认的 clang-format/rustfmt 条目）
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.c = { "lsp" }
      opts.formatters_by_ft.cpp = { "lsp" }
      opts.formatters_by_ft.rust = { "lsp" }
      return opts
    end,
  },
}
