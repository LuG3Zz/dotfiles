-- lua/config/lsp.lua — Mason + LSP 配置
-- 参考 Duy NG: https://gitlab.com/tduyng/nvim
-- 使用 Neovim 0.12 API: vim.lsp.config() + vim.lsp.enable()

-- ====== Mason: LSP 安装器 ======
require('mason').setup({})

-- ====== mason-lspconfig: 自动安装 ======
require('mason-lspconfig').setup({
  ensure_installed = { 'lua_ls', 'pyright', 'rust_analyzer', 'clangd' },
  automatic_installation = true,
})

-- ====== Per-server 配置 ======
-- nvim-lspconfig 的 lsp/*.lua 提供 cmd/filetypes/root_markers 基础配置
-- vim.lsp.config() 合并自定义 settings 进去

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

-- clangd 使用 lspconfig 默认配置

-- ====== 启用 LSP 服务器 ======
vim.lsp.enable({ 'lua_ls', 'pyright', 'rust_analyzer', 'clangd' })

-- ====== LspAttach：键位绑定 + 功能启用 ======
-- 使用 server_capabilities[has] 检查（非弃用 API）
local lsp_keys = {
  { keys = 'gd',             func = vim.lsp.buf.definition,         desc = 'Go to definition',         has = 'definitionProvider' },
  { keys = 'gI',             func = vim.lsp.buf.implementation,     desc = 'Go to implementation',     has = 'implementationProvider' },
  { keys = 'gy',             func = vim.lsp.buf.type_definition,    desc = 'Go to type definition',    has = 'typeDefinitionProvider' },
  { keys = 'gr',             func = vim.lsp.buf.references,         desc = 'Find references',          has = 'referencesProvider' },
  { keys = 'K',              func = vim.lsp.buf.hover,              desc = 'Hover documentation',      has = 'hoverProvider' },
  { keys = '<leader>ca',     func = vim.lsp.buf.code_action,        desc = 'Code action' },
  { keys = '<leader>rn',     func = vim.lsp.buf.rename,             desc = 'Rename symbol' },
  { keys = '<leader>li',     desc = 'Toggle inlay hints',           has = 'inlayHintProvider',
    func = function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}), nil)
    end },
  { keys = '<leader>ls',     func = function() vim.lsp.buf.document_symbol({}) end,
    desc = 'Document symbols', has = 'documentSymbolProvider' },
  { keys = '<leader>cw',     func = vim.lsp.buf.workspace_diagnostics, desc = 'Workspace diagnostics' },
  { keys = '<leader>cf',     desc = 'Format buffer',
    func = function() vim.lsp.buf.format({ async = true }) end },
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    local buf = args.buf
    local bufopts = { buffer = buf, silent = true }

    for _, km in ipairs(lsp_keys) do
      if not km.has or client.server_capabilities[km.has] then
        vim.keymap.set(km.mode or 'n', km.keys, km.func, vim.tbl_extend('force', bufopts, { desc = 'LSP: ' .. km.desc }))
      end
    end

    -- Inlay hints: Insert 模式暂时关闭，Leave 恢复
    if client.server_capabilities.inlayHintProvider and not vim.b[buf].inlay_hints_ready then
      vim.api.nvim_create_autocmd('InsertEnter', {
        buffer = buf, once = true,
        callback = function() vim.lsp.inlay_hint.enable(false, { bufnr = buf }) end,
      })
      vim.api.nvim_create_autocmd('InsertLeave', {
        buffer = buf, once = true,
        callback = function() vim.lsp.inlay_hint.enable(true, { bufnr = buf }) end,
      })
      vim.b[buf].inlay_hints_ready = true
    end
  end,
})

-- ====== Inlay Hints（默认开启） ======
vim.lsp.inlay_hint.enable(true, nil)

-- ====== On-Type Formatting（0.12 原生） ======
-- 支持的语言（如 rust-analyzer）会在输入 ; } 等时自动格式化
vim.lsp.on_type_formatting.enable()

-- ====== Format on Save ======
-- 用 `<leader>uf` 全局切换，`:FormatDisable!` buffer 局部切换
local auto_format_group = vim.api.nvim_create_augroup('UserAutoFormat', { clear = true })

vim.api.nvim_create_user_command('FormatDisable', function(opts)
  if opts.bang then vim.b.disable_autoformat = true
  else vim.g.disable_autoformat = true end
  vim.notify('Autoformat ' .. (opts.bang and 'buffer' or 'global') .. ' disabled', vim.log.levels.WARN)
end, { desc = 'Disable autoformat-on-save', bang = true })

vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.disable_autoformat = false; vim.g.disable_autoformat = false
  vim.notify('Autoformat enabled', vim.log.levels.INFO)
end, { desc = 'Re-enable autoformat-on-save' })

vim.keymap.set('n', '<leader>uf', function()
  if vim.g.disable_autoformat or vim.b.disable_autoformat then vim.cmd('FormatEnable')
  else vim.cmd('FormatDisable') end
end, { desc = 'Toggle autoformat' })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = auto_format_group,
  callback = function(args)
    if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then return end
    -- 只在有格式化能力的 LSP client 附加时才执行
    if #vim.lsp.get_clients({ bufnr = args.buf, method = 'textDocument/formatting' }) > 0 then
      vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
    end
  end,
})

-- ====== LSP 进度通知 ======
vim.api.nvim_create_autocmd('LspProgress', {
  group = vim.api.nvim_create_augroup('UserLspProgress', { clear = true }),
  callback = function(args)
    if args.data.message then
      vim.notify(args.data.message, vim.log.levels.INFO, { title = 'LSP: ' .. (args.data.server_name or ''), timeout = 3000 })
    end
  end,
})

-- ====== 诊断配置见 diagnostics.lua ======
