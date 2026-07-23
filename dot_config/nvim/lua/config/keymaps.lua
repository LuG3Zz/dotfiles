-- lua/config/keymaps.lua — 快捷键映射

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader 键设为空格
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ====== 基础操作 ======
map('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })
map('i', '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- ====== 窗口导航 ======
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Go to left window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Go to lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Go to upper window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Go to right window' })

-- ====== 窗口管理 ======
map('n', '<leader>wv', '<C-w>v', { desc = 'Split vertically' })
map('n', '<leader>wh', '<C-w>s', { desc = 'Split horizontally' })
map('n', '<leader>wq', '<C-w>q', { desc = 'Close window' })

-- ====== 文件浏览 (Oil) ======
map('n', '<leader>e', function()
  require('oil').open_float()
end, { desc = 'Open file explorer (float)' })

-- ====== 搜索 (mini.pick) ======
map('n', '<leader>f', '<cmd>Pick files<CR>', { desc = 'Find files' })
map('n', '<leader>g', '<cmd>Pick grep<CR>', { desc = 'Grep search' })
map('n', '<leader>b', '<cmd>Pick buffers<CR>', { desc = 'Find buffers' })
map('n', '<leader>h', '<cmd>Pick help<CR>', { desc = 'Find help' })

-- ====== 撤销历史 (内置 0.12) ======
map('n', '<leader>u', '<cmd>Undotree<CR>', { desc = 'Undo tree' })

-- ====== 文本操作 ======
map('n', '<leader>y', '"+y', { desc = 'Yank to clipboard' })
map('v', '<leader>y', '"+y', { desc = 'Yank to clipboard' })
map('n', '<leader>Y', '"+Y', { desc = 'Yank line to clipboard' })
map('n', '<leader>d', '"_d', { desc = 'Delete to black hole' })
map('v', '<leader>d', '"_d', { desc = 'Delete to black hole' })
map('n', '<leader>p', '"+p', { desc = 'Paste from clipboard' })
map('n', '<leader>P', '"+P', { desc = 'Paste from clipboard (before)' })

-- ====== 缓冲区 ======
map('n', '<leader>q', '<cmd>bdelete<CR>', { desc = 'Close buffer' })
map('n', '<leader>Q', '<cmd>qall<CR>', { desc = 'Quit all' })
map('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<S-Tab>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })

-- ====== OpenCode AI Agent ======
map({ 'n', 'v' }, '<C-a>', function()
  require('opencode').ask()
end, { desc = 'OpenCode: Ask' })

map({ 'n', 'v' }, '<C-x>', function()
  require('opencode').select()
end, { desc = 'OpenCode: Select command' })

map('n', 'go', function()
  require('opencode').operator()
end, { desc = 'OpenCode: Operator' })
