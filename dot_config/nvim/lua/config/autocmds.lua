-- lua/config/autocmds.lua — 自动命令

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- 通用用户事件组
local user_group = augroup('UserEvent', { clear = true })

-- Insert 模式下关闭相对行号
autocmd('InsertEnter', {
  group = user_group,
  callback = function()
    vim.opt.relativenumber = false
  end,
})

autocmd('InsertLeave', {
  group = user_group,
  callback = function()
    vim.opt.relativenumber = true
  end,
})

-- LspAttach: LSP 连接时绑定快捷键
local lsp_group = augroup('UserLspConfig', { clear = true })
autocmd('LspAttach', {
  group = lsp_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    local bufopts = { buffer = args.buf, silent = true }

    -- 跳转到定义
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', bufopts, { desc = 'LSP: Go to definition' }))
    -- 跳转到实现
    vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, vim.tbl_extend('force', bufopts, { desc = 'LSP: Go to implementation' }))
    -- 跳转到类型定义
    vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, vim.tbl_extend('force', bufopts, { desc = 'LSP: Go to type definition' }))
    -- 显示悬停文档
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', bufopts, { desc = 'LSP: Hover documentation' }))
    -- 跳转到引用
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', bufopts, { desc = 'LSP: References' }))
    -- 重命名
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', bufopts, { desc = 'LSP: Rename' }))
    -- Code action
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', bufopts, { desc = 'LSP: Code action' }))
    -- 上一个诊断
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', bufopts, { desc = 'LSP: Previous diagnostic' }))
    -- 下一个诊断
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', bufopts, { desc = 'LSP: Next diagnostic' }))
  end,
})

-- 文件类型检测
autocmd('FileType', {
  group = user_group,
  pattern = { 'json', 'yaml', 'yml', 'toml' },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})
