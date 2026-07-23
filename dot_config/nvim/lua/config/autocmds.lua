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

-- ====== 取自参考配置 ======

-- 切回窗口时自动重载文件改动
autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = user_group,
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

-- 复制时高亮文本
autocmd('TextYankPost', {
  group = user_group,
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- 终端窗口大小变化时自动均衡分屏
autocmd('VimResized', {
  group = user_group,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- man 页面不出现在 buffer list 中
autocmd('FileType', {
  group = user_group,
  pattern = { 'man' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- 指定文件类型可用 q 关闭窗口
autocmd('FileType', {
  group = user_group,
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

-- markdown/gitcommit 自动换行+拼写检查
autocmd('FileType', {
  group = user_group,
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- JSON 文件取消 conceallevel（防止键名被隐藏）
autocmd('FileType', {
  group = user_group,
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- 保存文件时自动创建中间目录
autocmd('BufWritePre', {
  group = user_group,
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- .env 文件设为 sh 语法
autocmd({ 'BufRead', 'BufNewFile' }, {
  group = user_group,
  pattern = { '*.env', '.env.*' },
  callback = function()
    vim.opt_local.filetype = 'sh'
  end,
})
