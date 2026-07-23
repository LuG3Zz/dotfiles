-- lua/config/lsp.lua — Mason + LSP 配置

-- Mason: LSP 安装器
local mason_ok, mason = pcall(require, 'mason')
if mason_ok then
  mason.setup({})
end

local ml_ok, ml = pcall(require, 'mason-lspconfig')
if ml_ok then
  ml.setup({
    ensure_installed = {
      'lua_ls',
      'pyright',
      'rust_analyzer',
      'clangd',
    },
    automatic_installation = true,
  })
end

-- LSP 配置（使用新 API vim.lsp.config，避免 lspconfig 弃用警告）
local servers = { 'lua_ls', 'pyright', 'rust_analyzer', 'clangd' }
for _, server in ipairs(servers) do
  local ok, config = pcall(require, 'lspconfig.configs.' .. server)
  if ok and config then
    vim.lsp.config[server] = vim.tbl_deep_extend('force', config.default_config, {})
  end
end

-- 诊断浮窗
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  float = {
    border = 'rounded',
    source = true,
    header = '',
    prefix = '',
  },
})
