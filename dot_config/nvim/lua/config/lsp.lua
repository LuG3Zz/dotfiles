-- lua/config/lsp.lua — Mason + LSP 配置
-- 参考 Duy NG: https://tduyng.com/blog/neovim-lsp-native/
-- 使用 Neovim 0.12 API: vim.lsp.config() + vim.lsp.enable()
-- nvim-lspconfig 提供 lsp/*.lua 基础配置，自动加载

-- ====== Mason: LSP 安装器 ======
require('mason').setup({})

-- ====== mason-lspconfig: 自动安装 ======
require('mason-lspconfig').setup({
  ensure_installed = { 'lua_ls', 'pyright', 'rust_analyzer', 'clangd' },
  automatic_installation = true,
})

-- ====== Per-server 配置（覆盖 lspconfig 默认值） ======
-- nvim-lspconfig 的 lsp/*.lua 提供 cmd/filetypes/root_markers 等基础配置
-- vim.lsp.config() 可合并自定义 settings
-- 完整配置列表: https://github.com/neovim/nvim-lspconfig/tree/master/lsp

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('', true),
      },
      telemetry = { enable = false },
      hint = {
        enable = true,
        setType = true,
        paramType = true,
        paramName = 'All',
      },
    },
  },
})

vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'basic',
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      },
    },
  },
})

vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = 'clippy' },
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
})

-- clangd 使用默认配置（lspconfig 已提供）

-- ====== 启用 LSP 服务器 ======
vim.lsp.enable({
  'lua_ls',
  'pyright',
  'rust_analyzer',
  'clangd',
})

-- ====== Inlay Hints（类型提示） ======
vim.lsp.inlay_hint.enable(true, nil)

-- ====== LSP 进度通知 ======
vim.api.nvim_create_autocmd('LspProgress', {
  group = vim.api.nvim_create_augroup('UserLspProgress', { clear = true }),
  callback = function(args)
    local data = args.data
    if data.message then
      vim.notify(data.message, vim.log.levels.INFO, {
        title = 'LSP: ' .. (data.server_name or ''),
        timeout = 3000,
      })
    end
  end,
})

-- LspAttach 键位绑定见 autocmds.lua
-- 诊断配置见 diagnostics.lua
