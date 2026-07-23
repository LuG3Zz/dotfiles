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

-- 智能 j/k：无 count 时按折行移动，有 count 时按实际行
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true })

-- gh/gl：行首行尾（比 ^/$ 更顺手）
map('n', 'gh', '^', { desc = 'Go to start of line' })
map('n', 'gl', '$', { desc = 'Go to end of line' })

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
  vim.schedule(function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, false, true), 'tm', false)
  end)
end, { desc = 'Open file explorer (float + preview)' })

-- ====== 搜索 (mini.pick) ======
map('n', '<leader>f', '<cmd>Pick files<CR>', { desc = 'Find files' })
map('n', '<leader>g', '<cmd>Pick grep<CR>', { desc = 'Grep search' })
map('n', '<leader>b', '<cmd>Pick buffers<CR>', { desc = 'Find buffers' })
map('n', '<leader>h', '<cmd>Pick help<CR>', { desc = 'Find help' })

-- 智能 n/N：n 总向前，N 总向后，不受搜索方向影响
map({ 'n', 'x', 'o' }, 'n', "'Nn'[v:searchforward]", { desc = 'Next search result', expr = true })
map({ 'n', 'x', 'o' }, 'N', "'nN'[v:searchforward]", { desc = 'Prev search result', expr = true })

-- ====== 撤销树 (mbbill/undotree) ======
map('n', '<leader>u', '<cmd>UndotreeToggle<CR>', { desc = 'Toggle undo tree' })

-- ====== 无干扰写作 ======
map('n', '<leader>z', function()
  require('zen-mode').toggle()
end, { desc = 'Toggle zen mode' })

-- ====== 文本操作 ======
map('n', '<leader>y', '"+y', { desc = 'Yank to clipboard' })
map('v', '<leader>y', '"+y', { desc = 'Yank to clipboard' })
map('n', '<leader>Y', '"+Y', { desc = 'Yank line to clipboard' })
map('n', '<leader>d', '"_d', { desc = 'Delete to black hole' })
map('v', '<leader>d', '"_d', { desc = 'Delete to black hole' })
map('n', '<leader>p', '"+p', { desc = 'Paste from clipboard' })
map('n', '<leader>P', '"+P', { desc = 'Paste from clipboard (before)' })

-- Visual 模式改进
map('v', '<', '<gv', { desc = 'Indent left and stay selected' })
map('v', '>', '>gv', { desc = 'Indent right and stay selected' })
map('v', 'p', '"_dP', { desc = 'Paste without losing clipboard' })

-- undo 断点：在自然停顿处分段
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', ';', ';<c-g>u')

-- ====== 缓冲区 ======
map('n', '<leader>q', '<cmd>bdelete<CR>', { desc = 'Close buffer' })
map('n', '<leader>Q', '<cmd>qall<CR>', { desc = 'Quit all' })
map('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<S-Tab>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
map('n', '<leader>bb', '<cmd>e #<CR>', { desc = 'Switch to other buffer' })

-- ====== 文件操作 ======
map('n', '<leader>fn', '<cmd>enew<CR>', { desc = 'New file' })
map('n', '<leader>tw', '<cmd>set wrap!<CR>', { desc = 'Toggle wrap', silent = true })

-- ====== 折叠导航 ======
map('n', 'zv', 'zMzvzz', { desc = 'Close all folds except current' })
map('n', 'zj', 'zcjzOzz', { desc = 'Close current fold, open next' })
map('n', 'zk', 'zckzOzz', { desc = 'Close current fold, open previous' })

-- ====== 检查工具 ======
map('n', '<leader>ui', vim.show_pos, { desc = 'Inspect highlight group' })
map('n', '<leader>uI', '<cmd>InspectTree<CR>', { desc = 'Inspect Treesitter tree' })

-- ====== Terminal 模式窗口导航 ======
map('t', '<C-h>', '<cmd>wincmd h<CR>', { desc = 'Terminal: Go to left window' })
map('t', '<C-j>', '<cmd>wincmd j<CR>', { desc = 'Terminal: Go to lower window' })
map('t', '<C-k>', '<cmd>wincmd k<CR>', { desc = 'Terminal: Go to upper window' })
map('t', '<C-l>', '<cmd>wincmd l<CR>', { desc = 'Terminal: Go to right window' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Terminal: Enter normal mode' })

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
