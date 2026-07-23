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
  gh('nvim-mini/mini.starter'),
  gh('stevearc/oil.nvim'),
  gh('saghen/blink.lib'),
  gh('saghen/blink.cmp'),
  gh('folke/which-key.nvim'),
  gh('mg979/vim-visual-multi'),
  gh('mason-org/mason.nvim'),
  gh('mason-org/mason-lspconfig.nvim'),
  gh('neovim/nvim-lspconfig'),
  gh('alker0/chezmoi.vim'),
  gh('nickjvandyke/opencode.nvim'),
})

-- 显式加载需要在 init 期间配置的插件（opt/ 目录需 packadd）
-- chezmoi.vim 需在 filetype/syntax 之前加载，放最前
vim.cmd.packadd('chezmoi.vim')
vim.cmd.packadd('nvim')                -- catppuccin/nvim
vim.cmd.packadd('nvim-treesitter')
vim.cmd.packadd('mini.pick')
vim.cmd.packadd('mini.ai')
vim.cmd.packadd('mini.surround')
vim.cmd.packadd('mini.starter')
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

-- ====== 启动 Dashboard ======
local starter_ok, starter = pcall(require, 'mini.starter')
if starter_ok then
  -- ██████╗ BROWNLU ██╗   ██╗ logo
  local logo = {
    '██████╗ ██████╗  ██████╗ ██╗    ██╗███╗   ██╗██╗     ██╗   ██╗',
    '██╔══██╗██╔══██╗██╔═══██╗██║    ██║████╗  ██║██║     ██║   ██║',
    '██████╔╝██████╔╝██║   ██║██║ █╗ ██║██╔██╗ ██║██║     ██║   ██║',
    '██╔══██╗██╔══██╗██║   ██║██║███╗██║██║╚██╗██║██║     ██║   ██║',
    '██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗╚██████╔╝',
    '╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝',
  }

  -- 自定义 header hook：在顶部插入 logo
  local header_hook = function(content)
    local header = {}
    table.insert(header, { { type = 'empty', string = '' } })
    for _, line in ipairs(logo) do
      table.insert(header, { { type = 'empty', string = line } })
    end
    table.insert(header, { { type = 'empty', string = '' } })
    table.insert(header, { { type = 'empty', string = '   Welcome back, brownlu' } })
    table.insert(header, { { type = 'empty', string = '' } })
    for i = #header, 1, -1 do
      table.insert(content, 1, header[i])
    end
    return content
  end

  -- 自定义 dotfiles 操作入口
  local dotfiles_section = {
    { name = 'Edit Neovim config',     action = 'lua vim.cmd("edit ~/.config/nvim/init.lua")',      section = 'Dotfiles (chezmoi)' },
    { name = 'Edit Zsh config',        action = 'lua vim.cmd("edit ~/.zshrc")',                     section = 'Dotfiles (chezmoi)' },
    { name = 'Edit Tmux config',       action = 'lua vim.cmd("edit ~/.tmux.conf")',                 section = 'Dotfiles (chezmoi)' },
    { name = 'Edit Keyd config',       action = 'lua vim.cmd("edit /etc/keyd/default.conf")',       section = 'Dotfiles (chezmoi)' },
    { name = 'Edit Hyprland config',   action = 'lua vim.cmd("edit ~/.config/hypr/hyprland.conf")', section = 'Dotfiles (chezmoi)' },
    { name = 'Chezmoi apply',          action = '!cd ~/.local/share/chezmoi && chezmoi apply',      section = 'Dotfiles (chezmoi)' },
    { name = 'Chezmoi status',         action = '!cd ~/.local/share/chezmoi && git status',         section = 'Dotfiles (chezmoi)' },
  }

  starter.setup({
    evaluate_single = true,
    items = {
      dotfiles_section,
      starter.sections.builtin_actions(),
      starter.sections.recent_files(10, false),
      starter.sections.recent_files(10, true),
      starter.sections.sessions(5, true),
    },
    content_hooks = {
      header_hook,
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.indexing('all', { 'Dotfiles (chezmoi)', 'Builtin Actions' }),
      starter.gen_hook.padding(1, 1),
    },
  })
end

-- ====== 文件浏览 ======
local oil_ok, oil = pcall(require, 'oil')
if oil_ok then
  oil.setup({
    default_file_explorer = true,
    float = {
      max_width = 0.6,
      max_height = 0.8,
      border = 'rounded',
    },
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
