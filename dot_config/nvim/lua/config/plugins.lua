-- lua/config/plugins.lua — 插件声明（vim.pack）与配置
-- 所有 vim.pack.add() 调用在此文件集中完成

-- Helper: 返回完整 GitHub URL
local gh = function(repo)
  return 'https://github.com/' .. repo
end

-- 注册所有插件（已在磁盘上，仅快速注册 + 生成 lock 文件）
vim.pack.add({
  gh('ellisonleao/gruvbox.nvim'),
  gh('catppuccin/nvim'),
  gh('nvim-treesitter/nvim-treesitter'),
  gh('nvim-mini/mini.pick'),
  gh('nvim-mini/mini.ai'),
  gh('nvim-mini/mini.surround'),
  gh('nvim-mini/mini.icons'),
  gh('nvim-mini/mini.cursorword'),
  gh('nvim-mini/mini.sessions'),
  gh('nvim-mini/mini.move'),
  gh('nvim-mini/mini.comment'),
  gh('monaqa/dial.nvim'),
  gh('nvim-zh/colorful-winsep.nvim'),
  gh('folke/snacks.nvim'),
  gh('nvim-mini/mini.statusline'),
  gh('HiPhish/rainbow-delimiters.nvim'),
  gh('Bekaboo/dropbar.nvim'),
  gh('stevearc/oil.nvim'),
  gh('stevearc/aerial.nvim'),
  gh('saghen/blink.lib'),
  gh('saghen/blink.cmp'),
  gh('folke/which-key.nvim'),
  { src = gh('kkew3/jieba.vim'), branch = 'release' },
  gh('yaocccc/visual-multi.nvim'),
  gh('mason-org/mason.nvim'),
  gh('mason-org/mason-lspconfig.nvim'),
  gh('neovim/nvim-lspconfig'),
  gh('alker0/chezmoi.vim'),
  gh('nickjvandyke/opencode.nvim'),
  gh('nvim-mini/mini.pairs'),
  gh('folke/flash.nvim'),
  gh('mbbill/undotree'),
  gh('kevinhwang91/nvim-ufo'),
  gh('kevinhwang91/promise-async'),
  gh('lewis6991/gitsigns.nvim'),
  -- lazygit: 使用 snacks.lazygit
  gh('rafamadriz/friendly-snippets'),
  gh('sphamba/smear-cursor.nvim'),
  gh('rachartier/tiny-cmdline.nvim'),
  gh('nvim-lua/plenary.nvim'),
  gh('epwalsh/obsidian.nvim'),
  gh('skywind3000/asyncrun.vim'),
  gh('skywind3000/asynctasks.vim'),
  gh('OXY2DEV/markview.nvim'),
})

-- 显式加载需要在 init 期间配置的插件（opt/ 目录需 packadd）
-- chezmoi.vim 需在 filetype/syntax 之前加载，放最前
vim.cmd.packadd('chezmoi.vim')
vim.cmd.packadd('gruvbox.nvim')
vim.cmd.packadd('nvim')                -- catppuccin/nvim
vim.cmd.packadd('nvim-treesitter')
vim.cmd.packadd('mini.pick')
vim.cmd.packadd('mini.ai')
vim.cmd.packadd('mini.surround')
vim.cmd.packadd('mini.icons')
vim.cmd.packadd('mini.cursorword')
vim.cmd.packadd('mini.sessions')
vim.cmd.packadd('mini.move')
vim.cmd.packadd('mini.comment')
vim.cmd.packadd('dial.nvim')
vim.cmd.packadd('colorful-winsep.nvim')
-- dial.nvim 的 augends 在下面的 setup 中配置
vim.cmd.packadd('snacks.nvim')
vim.cmd.packadd('mini.statusline')
vim.cmd.packadd('rainbow-delimiters.nvim')
vim.cmd.packadd('dropbar.nvim')
vim.cmd.packadd('oil.nvim')
vim.cmd.packadd('aerial.nvim')
vim.cmd.packadd('blink.lib')            -- blink.cmp 依赖
vim.cmd.packadd('blink.cmp')
-- jieba.vim 需要先设配置再 packadd，否则 g: 变量读不到
vim.g.jieba_vim_lazy = 1
vim.g.jieba_vim_keymap = 1

vim.cmd.packadd('jieba.vim')

vim.cmd.packadd('visual-multi.nvim')
vim.cmd.packadd('which-key.nvim')
vim.cmd.packadd('mason.nvim')
vim.cmd.packadd('mason-lspconfig.nvim')
vim.cmd.packadd('nvim-lspconfig')
vim.cmd.packadd('opencode.nvim')
vim.cmd.packadd('mini.pairs')
vim.cmd.packadd('flash.nvim')
vim.cmd.packadd('undotree')
vim.cmd.packadd('promise-async')
vim.cmd.packadd('nvim-ufo')
vim.cmd.packadd('gitsigns.nvim')
vim.cmd.packadd('friendly-snippets')
vim.cmd.packadd('smear-cursor.nvim')
vim.g.tiny_cmdline = {
  width = { value = '70%' },
  prompt_prefix = ' ',
  position = { y = '25%' },
}
vim.cmd.packadd('tiny-cmdline.nvim')
vim.cmd.packadd('plenary.nvim')
vim.cmd.packadd('obsidian.nvim')
vim.cmd.packadd('asyncrun.vim')
vim.cmd.packadd('asynctasks.vim')
vim.cmd.packadd('markview.nvim')

-- ====== 主题：Gruvbox ======
local gruvbox_ok, gruvbox = pcall(require, 'gruvbox')
if gruvbox_ok then
  gruvbox.setup({
    transparent_mode = true,
    contrast = 'soft',
    italic = { strings = false, comments = false },
    overrides = {},
  })
  vim.cmd.colorscheme('gruvbox')
end

-- catppuccin 备用（切换: :colorscheme catppuccin）
local cp_ok, cp = pcall(require, 'catppuccin')
if cp_ok then
  cp.setup({
    flavour = 'mocha',
    transparent_background = true,
    no_italic = true,
    integrations = {
      treesitter = true, cmp = true, snacks = true, mini = true,
    },
  })
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

-- ====== 光标下单词高亮 ======
local cw_ok, cw = pcall(require, 'mini.cursorword')
if cw_ok then
  cw.setup({})
end

-- ====== Session 管理 ======
local s_ok, s = pcall(require, 'mini.sessions')
if s_ok then
  s.setup({
    autoread = false,
    autowrite = false,
    directory = vim.fn.stdpath('state') .. '/sessions',
  })
end

-- 自动保存开关
vim.g.autosave_session = false

-- ====== 行移动增强 ======
local mv_ok, mv = pcall(require, 'mini.move')
if mv_ok then
  mv.setup({
    mappings = {
      left = '<M-h>',
      right = '<M-l>',
      down = '<M-j>',
      up = '<M-k>',
    },
  })
end

-- ====== 智能注释 ======
local cm_ok, cm = pcall(require, 'mini.comment')
if cm_ok then
  cm.setup({})
end

-- ====== 增量改值增强 (dial.nvim) ======
-- 在默认基础上增加 boolean、字母、英式星期等
local dial_config = require('dial.config')
local constant = require('dial.augend.constant')
local default_augends = dial_config.augends:get('default')
vim.list_extend(default_augends, {
  constant.alias.bool,
  constant.alias.Bool,
  constant.alias.alpha,
  constant.alias.Alpha,
  constant.alias.en_weekday,
})

-- ====== 文件类型图标 ======
local icons_ok, icons = pcall(require, 'mini.icons')
if icons_ok then
  icons.setup({})
  -- mini.pick 集成
  require('mini.pick').setup({
    source = {
      show_icons = true,
    },
  })
end

-- ====== 光标动画 (smear-cursor) ======
local smear_ok, smear = pcall(require, 'smear_cursor')
if smear_ok then
  smear.setup({
    stiffness = 0.7,
    trailing_stiffness = 0.5,
    distance_stop_animating = 0.5,
  })
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
    -- 动画效果
    animate = { enabled = true },
    -- 作用域检测（dim 依赖）
    scope = { enabled = true },
    -- 焦点区域暗化
    dim = {
      enabled = true,
      scope = { enabled = true },
    },
    -- Zen 模式（替代 folke/zen-mode.nvim）
    zen = { enabled = true },
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

-- ====== 状态栏 (mini.statusline) ======
local sl_ok, sl = pcall(require, 'mini.statusline')
if sl_ok then
  sl.setup({
    use_icons = true,
    set_vim_settings = false,
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

-- ====== 代码大纲 (aerial) ======
local aerial_ok, aerial = pcall(require, 'aerial')
if aerial_ok then
  aerial.setup({
    -- 右侧纵向分割窗口
    layout = { width = 35, default_direction = 'prefer_right' },
    -- 显示所有符号（函数、变量、类等）
    filter_kind = { 'Class', 'Constructor', 'Enum', 'Function', 'Interface', 'Method', 'Struct', 'Variable' },
    -- 关闭其他大纲视图（单例模式）
    close_behavior = 'auto',
    -- 使用优先级：LSP > Treesitter
    sources = { 'lsp', 'treesitter' },
  })
end

-- ====== 快捷键提示 (which-key) ======
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

-- ====== Zen 模式 (snacks.zen) ======
-- <leader>z 触发，已集成在 snacks 中

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

-- ====== Obsidian 笔记集成 ======
local obs_ok, obs = pcall(require, 'obsidian')
if obs_ok then
  obs.setup({
    -- 动态检测 vault：从当前文件向上找 .obsidian 目录
    workspaces = {
      {
        name = 'auto',
        path = function()
          local f = vim.fn.expand('%:p')
          if f == '' then return '~/Documents/OB/ALL-IN-ONE' end
          local root = vim.fs.root(f, '.obsidian')
          return root or '~/Documents/OB/ALL-IN-ONE'
        end,
      },
    },
    daily_notes = {
      folder = 'Daily',
      date_format = '%Y-%m-%d',
    },
    -- 模板（与 Templater 共用同一目录）
    templates = {
      folder = '06-附件/模板',
      date_format = '%Y-%m-%d',
      time_format = '%H:%M',
      substitutions = {},
    },
    completion = {
      nvim_cmp = false,  -- 用 blink.cmp
    },
    picker = {
      name = 'mini.pick',
    },
    ui = { enable = true },
    new_notes_location = 'current_dir',
    mappings = {
      ['<leader>ch'] = {
        action = function() return require('obsidian').util.toggle_checkbox() end,
        opts = { buffer = true },
      },
    },
  })
end

-- ====== 多光标 (yaocccc/visual-multi.nvim) ======
-- <C-n> 选词，<C-d> 全选，<C-Up/Down> 行光标，q 跳过

-- ====== 代码结构导航栏 (dropbar) ======
local dropbar_ok, dropbar = pcall(require, 'dropbar')
if dropbar_ok then
  dropbar.setup({
    bar = {
      sources = function(buf, _)
        -- 终端缓冲区不显示 winbar
        if vim.bo[buf].buftype == 'terminal' then return {} end
        local sources = require('dropbar.sources')
        local utils = require('dropbar.utils')
        return {
          utils.source.fallback({ sources.lsp, sources.treesitter, sources.path }),
        }
      end,
      truncate = true,
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
      local text = vim.fn.getline(lnum):gsub('^%s+', '')
      local suffix = ' …  ' .. (end_lnum - lnum)
      if vim.fn.strdisplaywidth(text) > width - 6 then
        text = truncate(text, width - 6)
      end
      return {
        { text, 'NormalFloat' },
        { suffix, 'Comment' },
      }
    end,
    open_fold_hl_timeout = 200,
    preview = {
      win_config = {
        border = 'rounded',
        winblend = 12,
        maxheight = 15,
      },
    },
  })
end

-- ====== 彩虹括号 ======
-- rainbow-delimiters.nvim: 使用 Treesitter 高亮括号层级
-- 默认配置即可工作，无需额外 setup

-- ====== AsyncRun + AsyncTasks 配置 ======
vim.g.asyncrun_open = 0     -- 不自动打开 quickfix（由 asynctasks 控制）
vim.g.asynctasks_term_pos = 'bottom'  -- 终端模式默认位置
vim.g.asynctasks_term_rows = 12       -- 终端高度
vim.g.asynctasks_term_reuse = 1       -- 复用已有终端窗口

-- ====== Markdown 预览 (markview.nvim) ======
local mv_ok, mv = pcall(require, 'markview')
if mv_ok then
  mv.setup({
    preview = {
      enable = true,
      filetypes = { 'markdown', 'md' },
    },
  })
end

-- ====== 彩色窗口分隔线 ======
local ws_ok, ws = pcall(require, 'colorful-winsep')
if ws_ok then
  ws.setup({})
end

-- ====== 其余插件 ======
-- blink.cmp 配置在 completion.lua 中
-- Mason + lspconfig 配置在 lsp.lua 中
-- opencode.nvim 配置在 agent.lua 中
