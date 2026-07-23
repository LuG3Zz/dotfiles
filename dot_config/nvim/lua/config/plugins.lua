-- lua/config/plugins.lua — 插件声明（vim.pack）与配置
-- 所有 vim.pack.add() 调用在此文件集中完成

-- Helper: 返回完整 GitHub URL
local gh = function(repo)
  return 'https://github.com/' .. repo
end

-- 注册所有插件（已在磁盘上，仅快速注册 + 生成 lock 文件）
vim.pack.add({
  gh('catppuccin/nvim'),
  gh('nvim-treesitter/nvim-treesitter'),
  gh('nvim-mini/mini.pick'),
  gh('nvim-mini/mini.ai'),
  gh('nvim-mini/mini.surround'),
  gh('stevearc/oil.nvim'),
  gh('saghen/blink.lib'),
  gh('saghen/blink.cmp'),
  gh('folke/which-key.nvim'),
  gh('mg979/vim-visual-multi'),
  gh('mason-org/mason.nvim'),
  gh('mason-org/mason-lspconfig.nvim'),
  gh('neovim/nvim-lspconfig'),
  gh('nickjvandyke/opencode.nvim'),
})

-- 显式加载需要在 init 期间配置的插件（opt/ 目录需 packadd）
vim.cmd.packadd('nvim')                -- catppuccin/nvim
vim.cmd.packadd('nvim-treesitter')
vim.cmd.packadd('mini.pick')
vim.cmd.packadd('mini.ai')
vim.cmd.packadd('mini.surround')
vim.cmd.packadd('oil.nvim')
vim.cmd.packadd('blink.lib')            -- blink.cmp 依赖
vim.cmd.packadd('blink.cmp')
vim.cmd.packadd('which-key.nvim')
vim.cmd.packadd('mason.nvim')
vim.cmd.packadd('mason-lspconfig.nvim')
vim.cmd.packadd('nvim-lspconfig')
vim.cmd.packadd('opencode.nvim')

-- ====== 主题：Catppuccin Mocha ======
local catppuccin_ok, catppuccin = pcall(require, 'catppuccin')
if catppuccin_ok then
  catppuccin.setup({
    flavour = 'mocha',
    transparent_background = true,
    no_italic = true,
    integrations = {
      treesitter = true,
      cmp = true,
      indent_blankline = { enabled = false },
    },
  })
  vim.cmd.colorscheme('catppuccin')
end

-- ====== Treesitter ======
local ts_ok, ts = pcall(require, 'nvim-treesitter.configs')
if ts_ok then
  ts.setup({
    ensure_installed = { 'lua', 'python', 'rust', 'c', 'cpp', 'markdown' },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end

-- ====== 文件搜索 ======
local pick_ok, pick = pcall(require, 'mini.pick')
if pick_ok then
  pick.setup({})
end

-- ====== 文本对象增强 ======
local ai_ok, ai = pcall(require, 'mini.ai')
if ai_ok then
  ai.setup({})
end

-- ====== 环绕编辑 ======
local surround_ok, surround = pcall(require, 'mini.surround')
if surround_ok then
  surround.setup({})
end

-- ====== 文件浏览 ======
local oil_ok, oil = pcall(require, 'oil')
if oil_ok then
  oil.setup({
    default_file_explorer = true,
    keymaps = {
      ['<C-h>'] = false,
      ['<M-h>'] = 'actions.select_split',
    },
  })
end

-- ====== 快捷键提示 ======
local wk_ok, wk = pcall(require, 'which-key')
if wk_ok then
  wk.setup({
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = false },
    },
  })
end

-- ====== 多光标 ======
-- vim-visual-multi: 使用默认键位
-- <C-n> 选词，<C-x> 跳过，<C-p> 移除

-- ====== 其余插件 ======
-- blink.cmp 配置在 completion.lua 中
-- Mason + lspconfig 配置在 lsp.lua 中
-- opencode.nvim 配置在 agent.lua 中
