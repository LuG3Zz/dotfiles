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
  gh('folke/snacks.nvim'),
  gh('nvim-lualine/lualine.nvim'),
  gh('HiPhish/rainbow-delimiters.nvim'),
  gh('Bekaboo/dropbar.nvim'),
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
  gh('nvim-mini/mini.pairs'),
  gh('folke/flash.nvim'),
  gh('mbbill/undotree'),
  gh('folke/zen-mode.nvim'),
  gh('folke/noice.nvim'),
  gh('MunifTanjim/nui.nvim'),
  gh('kevinhwang91/nvim-ufo'),
  gh('kevinhwang91/promise-async'),
  gh('lewis6991/gitsigns.nvim'),
  gh('kdheepak/lazygit.nvim'),
  gh('L3MON4D3/LuaSnip'),
  gh('rafamadriz/friendly-snippets'),
})

-- 显式加载需要在 init 期间配置的插件（opt/ 目录需 packadd）
-- chezmoi.vim 需在 filetype/syntax 之前加载，放最前
vim.cmd.packadd('chezmoi.vim')
vim.cmd.packadd('nvim')                -- catppuccin/nvim
vim.cmd.packadd('nvim-treesitter')
vim.cmd.packadd('mini.pick')
vim.cmd.packadd('mini.ai')
vim.cmd.packadd('mini.surround')
vim.cmd.packadd('snacks.nvim')
vim.cmd.packadd('lualine.nvim')
vim.cmd.packadd('rainbow-delimiters.nvim')
vim.cmd.packadd('dropbar.nvim')
vim.cmd.packadd('oil.nvim')
vim.cmd.packadd('blink.lib')            -- blink.cmp 依赖
vim.cmd.packadd('blink.cmp')
vim.cmd.packadd('which-key.nvim')
vim.cmd.packadd('mason.nvim')
vim.cmd.packadd('mason-lspconfig.nvim')
vim.cmd.packadd('nvim-lspconfig')
vim.cmd.packadd('opencode.nvim')
vim.cmd.packadd('mini.pairs')
vim.cmd.packadd('flash.nvim')
vim.cmd.packadd('undotree')
vim.cmd.packadd('zen-mode.nvim')
vim.cmd.packadd('noice.nvim')
vim.cmd.packadd('nui.nvim')
vim.cmd.packadd('promise-async')
vim.cmd.packadd('nvim-ufo')
vim.cmd.packadd('gitsigns.nvim')
vim.cmd.packadd('lazygit.nvim')
vim.cmd.packadd('LuaSnip')
vim.cmd.packadd('friendly-snippets')

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
      snacks = true,
      noice = true,
      mini = true,
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

-- ====== snacks.nvim 一体化增强 ======
-- 提供 UI 增强：Dashboard、通知、缩进线、滚动条、状态列
local snacks_ok, snacks = pcall(require, 'snacks')
if snacks_ok then
  snacks.setup({
    -- 启动 Dashboard（替换 mini.starter）
    dashboard = {
      enabled = true,
      preset = {
        header = [[
    ██████╗ ██████╗  ██████╗ ██╗    ██╗███╗   ██╗██╗     ██╗   ██╗
    ██╔══██╗██╔══██╗██╔═══██╗██║    ██║████╗  ██║██║     ██║   ██║
    ██████╔╝██████╔╝██║   ██║██║ █╗ ██║██╔██╗ ██║██║     ██║   ██║
    ██╔══██╗██╔══██╗██║   ██║██║███╗██║██║╚██╗██║██║     ██║   ██║
    ██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗╚██████╔╝
    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝
        ]],
        keys = {
          { icon = '󰛓 ', key = 'd', desc = 'Dotfiles (chezmoi)', action = ':lua require("mini.pick").start({ source = { items = vim.fn.systemlist({"find", vim.fn.expand("~/.local/share/chezmoi"), "-type", "f", "-not", "-path", "*/.git/*"}), name = "Dotfiles" } })' },
          { icon = ' ', key = 'f', desc = 'Find File',          action = ':Pick files' },
          { icon = ' ', key = 'r', desc = 'Recent Files',       action = ':lua require("mini.pick").start({ source = { items = vim.v.oldfiles, name = "Recent files" } })' },
          { icon = ' ', key = 'q', desc = 'Quit',               action = ':qa' },
        },
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'hitokoto' },
      },
    },
    -- 通知系统（替换默认 vim.notify）
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    -- 缩进指示线（替代 indent-blankline）
    indent = {
      enabled = true,
      indent = {
        animate = { enabled = true },
      },
      chunk = {
        enabled = true,
        only_current = true,
      },
    },
    -- 右侧滚动条
    scroll = {
      enabled = true,
    },
    -- 增强状态列（行号区 + fold/git/diagnostic）
    statuscolumn = {
      enabled = true,
    },
    -- 浮动输入框
    input = {
      enabled = true,
      win = {
        border = 'rounded',
        width = 0.5,
      },
    },
    -- 浮动终端
    terminal = {
      enabled = true,
      win = {
        style = 'float',
        relative = 'editor',
        width = 0.8,
        height = 0.8,
        border = 'rounded',
      },
    },
    -- 禁用不需要的组件
    bigfile = { enabled = true },
    picker = { enabled = false },    -- 使用 mini.pick
    words = { enabled = false },     -- 使用 LSP
    quickfile = { enabled = true },
  })

  -- 注册一言格言 section（每次打开 Dashboard 时刷新）
  local hitokoto_ok, hitokoto = pcall(require, 'config.hitokoto')
  if hitokoto_ok then
    snacks.dashboard.sections.hitokoto = function()
      return {
        align = 'center',
        text = { { hitokoto.dashboard_text(), hl = 'SpecialComment' } },
      }
    end
  end
end

-- ====== 状态栏 (lualine) ======
local lualine_ok, lualine = pcall(require, 'lualine')
if lualine_ok then
  lualine.setup({
    options = {
      theme = 'catppuccin-mocha',
      icons_enabled = true,
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = { statusline = { 'dashboard', 'alpha' } },
      globalstatus = true,
    },
    sections = {
      lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = { 'filetype', 'encoding', 'fileformat' },
      lualine_y = { 'progress' },
      lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
    },
    extensions = { 'oil' },
  })
end

-- ====== 文件浏览 ======
local oil_ok, oil = pcall(require, 'oil')
if oil_ok then
  oil.setup({
    default_file_explorer = true,
    preview_win = {
      update_on_cursor_moved = true,
      preview_method = 'fast_scratch',
      win_options = {
        winhl = 'Normal:NormalFloat',
      },
    },
    float = {
      max_width = 0.6,
      max_height = 0.8,
      border = 'rounded',
      preview_split = 'auto',
    },
    keymaps = {
      ['q'] = 'actions.close',
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

-- ====== 自动补全括号/引号 (mini.pairs) ======
local pairs_ok, pairs = pcall(require, 'mini.pairs')
if pairs_ok then
  pairs.setup({})
end

-- ====== 增强字符跳转 (f/t) ======
local flash_ok, flash = pcall(require, 'flash')
if flash_ok then
  flash.setup({
    modes = {
      char = {
        enabled = true,
        jump_labels = true,
      },
    },
    highlight = {
        backdrop = true,
        groups = { match = 'DiffAdd', label = 'String' },
    },
  })
end

-- ====== 撤销树浏览 ======
-- mbbill/undotree: `<leader>u` 切换撤销树
-- 已通过 pcall 安全加载，无需额外 setup

-- ====== 无干扰写作模式 ======
local zen_ok, zen = pcall(require, 'zen-mode')
if zen_ok then
  zen.setup({
    window = {
      options = {
        number = true,
        relativenumber = true,
      },
    },
    plugins = {
      options = {
        enabled = true,
        ruler = false,
        showcmd = false,
      },
      tmux = { enabled = false }, -- 未使用 tmux
      kitty = { enabled = false },
      alacritty = { enabled = false },
    },
  })
end

-- ====== Git 标记 (gitsigns) ======
local gs_ok, gs = pcall(require, 'gitsigns')
if gs_ok then
  gs.setup({
    signs = {
      add = { text = '│' },
      change = { text = '│' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    current_line_blame = false,       -- 用 <leader>gb 触发
    signcolumn = true,
    numhl = false,
    watch_gitdir = { interval = 1000 },
  })
end

-- ====== Lazygit 集成 ======
-- kdheepak/lazygit.nvim 无需 setup，直接调用
-- require('lazygit').lazygit() 或 require('lazygit').lazygitcurrentfile()

-- ====== 多光标 ======
-- vim-visual-multi: 使用默认键位
-- <C-n> 选词，<C-x> 跳过，<C-p> 移除

-- ====== 代码结构导航栏 (dropbar) ======
local dropbar_ok, dropbar = pcall(require, 'dropbar')
if dropbar_ok then
  dropbar.setup({
    bar = {
      sources = function(buf, _)
        local sources = require('dropbar.sources')
        local utils = require('dropbar.utils')
        -- LSP 优先，显示函数/类层级；回退到 treesitter 再到文件路径
        return {
          utils.source.fallback({ sources.lsp, sources.treesitter, sources.path }),
        }
      end,
      truncate = true,
    },
  })
end

-- ====== 命令美化 (noice.nvim) ======
local noice_ok, noice = pcall(require, 'noice')
if noice_ok then
  noice.setup({
    cmdline = {
      enabled = true,
      view = 'cmdline_popup',
    },
    messages = {
      enabled = true,
      view = 'notify',
    },
    popupmenu = {
      enabled = true,
      backend = 'nui',
    },
    lsp = {
      progress = { enabled = false },
      signature = { enabled = false },
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylify_markdown'] = true,
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
  })
end

-- ====== 折叠增强 (nvim-ufo) ======
local ufo_ok, ufo = pcall(require, 'ufo')
if ufo_ok then
  ufo.setup({
    provider_selector = function()
      return { 'treesitter', 'indent' }
    end,
    fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
      local text = vim.fn.getline(lnum):gsub('^%s+', ''):gsub('{.*', '')
      local line_count = end_lnum - lnum
      return {
        { text, 'NormalFloat' },
        { '  ' .. line_count .. ' lines', 'Comment' },
      }
    end,
  })
end

-- ====== 代码片段 (LuaSnip) ======
local luasnip_ok, luasnip = pcall(require, 'luasnip')
if luasnip_ok then
  -- 加载 friendly-snippets
  require('luasnip.loaders.from_vscode').lazy_load()
  luasnip.setup({
    history = true,
    update_events = 'TextChanged,TextChangedI',
    enable_autosnippets = true,
  })
end

-- ====== 彩虹括号 ======
-- rainbow-delimiters.nvim: 使用 Treesitter 高亮括号层级
-- 默认配置即可工作，无需额外 setup

-- ====== 其余插件 ======
-- blink.cmp 配置在 completion.lua 中
-- Mason + lspconfig 配置在 lsp.lua 中
-- opencode.nvim 配置在 agent.lua 中
