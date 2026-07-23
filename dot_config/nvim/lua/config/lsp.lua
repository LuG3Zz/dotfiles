-- lua/config/lsp.lua — Mason + LSP 配置
-- 使用 Neovim 0.12 API: vim.lsp.config + vim.lsp.enable

-- ====== Mason: LSP/DAP 安装器 ======
local mason_ok, mason = pcall(require, 'mason')
if mason_ok then
  mason.setup({})
end

-- ====== mason-lspconfig: 自动安装 + 启用 ======
local ml_ok, ml = pcall(require, 'mason-lspconfig')
if ml_ok then
  ml.setup({
    ensure_installed = { 'lua_ls', 'pyright', 'rust_analyzer', 'clangd' },
    automatic_installation = true,
  })
end

-- ====== Per-server 配置（vim.lsp.config API） ======
-- 合并 lspconfig 默认配置 + 自定义 settings

local servers = {
  lua_ls = {
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
  },
  pyright = {
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
  },
  rust_analyzer = {
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
  },
  clangd = {
    settings = {},
  },
  -- 在此添加更多服务器
}

-- 通用 LSP capabilities（全开）
local common_capabilities = vim.tbl_deep_extend('force',
  vim.lsp.protocol.make_client_capabilities(),
  {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = true },
      symbol = { dynamicRegistration = true },
    },
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          resolveSupport = { properties = { 'documentation', 'detail', 'additionalTextEdits' } },
        },
      },
      foldingRange = { dynamicRegistration = true },
      selectionRange = { dynamicRegistration = true },
    },
    window = { workDoneProgress = true },
  }
)

-- 注册并启用各服务器
for server_name, user_config in pairs(servers) do
  local ok, lspconfig_config = pcall(require, 'lspconfig.configs.' .. server_name)
  if ok and lspconfig_config and lspconfig_config.default_config then
    vim.lsp.config[server_name] = vim.tbl_deep_extend('force',
      lspconfig_config.default_config,
      user_config,
      { capabilities = common_capabilities }
    )
  else
    vim.lsp.config[server_name] = vim.tbl_deep_extend('force',
      user_config,
      { capabilities = common_capabilities }
    )
  end
  vim.lsp.enable(server_name)
end

-- ====== Inlay Hints（类型提示） ======
vim.lsp.inlay_hint.enable(true, nil)

-- ====== LSP 增强功能 ======
-- 所有 LSP 相关键位见 autocmds.lua (LspAttach)

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

-- 诊断配置见 diagnostics.lua（优先级更高，已包含 linehl 等增强）
