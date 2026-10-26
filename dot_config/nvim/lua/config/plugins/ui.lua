-- lua/config/plugins/ui.lua — 界面与外观
-- 主题 / snacks 一体化 UI / 启动页 / 状态栏 / which-key / 窗口分隔线 / 光标动画

-- ====== 主题：默认 gruvbox ======
-- 只加载持久化记录的那套主题；另一套在 <leader>ut 切换时才 require
local theme = require("config.theme")
theme.apply(theme.saved())

-- ====== snacks.nvim 一体化增强 ======
-- 提供 UI 增强：Dashboard、通知、缩进线、滚动条、状态列
local snacks_ok, snacks = pcall(require, "snacks")
if snacks_ok then
  snacks.setup({
    -- 通知系统（替换默认 vim.notify）
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    -- 缩进指示线（Dashboard 已排除，不会显示）
    indent = {
      enabled = true,
      indent = {
        animate = { enabled = true },
      },
      chunk = {
        enabled = true,
        only_current = true,
      },
      filter = function(buf)
        if vim.bo[buf].buftype ~= "" then
          return false
        end
        if vim.bo[buf].filetype == "snacks_dashboard" then
          return false
        end
        return true
      end,
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
        border = "rounded",
        width = 0.5,
      },
    },
    -- 浮动终端
    terminal = {
      enabled = true,
      win = {
        style = "float",
        relative = "editor",
        width = 0.8,
        height = 0.8,
        border = "rounded",
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
    picker = { enabled = false }, -- 使用 mini.pick
    words = { enabled = false }, -- 使用 LSP
    quickfile = { enabled = true },
  })
end

-- ====== 启动页 (mini.starter) ======
local logo = {
  "██████╗ ██████╗  ██████╗ ██╗    ██╗███╗   ██╗██╗     ██╗   ██╗",
  "██╔══██╗██╔══██╗██╔═══██╗██║    ██║████╗  ██║██║     ██║   ██║",
  "██████╔╝██████╔╝██║   ██║██║ █╗ ██║██╔██╗ ██║██║     ██║   ██║",
  "██╔══██╗██╔══██╗██║   ██║██║███╗██║██║╚██╗██║██║     ██║   ██║",
  "██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗╚██████╔╝",
  "╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝",
}

local st_ok, st = pcall(require, "mini.starter")
if st_ok then
  st.setup({
    evaluate_single = true,
    items = {
      -- 搜索
      {
        name = "f    Find File",
        action = ":Pick files",
        section = "Search",
      },
      {
        name = "g    Grep",
        action = ":Pick grep",
        section = "Search",
      },
      {
        name = "r    Recent Files",
        action = ':lua require("mini.pick").start({ source = { items = vim.v.oldfiles, name = "Recent files" } })',
        section = "Search",
      },
      -- 项目
      {
        name = "d  󰛓  Dotfiles",
        action = ':lua require("mini.pick").start({ source = { items = vim.fn.systemlist({"find", vim.fn.expand("~/.local/share/chezmoi"), "-type", "f", "-not", "-path", "*/.git/*"}), name = "Dotfiles" } })',
        section = "Projects",
      },
      -- 笔记
      {
        name = "w    Vimwiki",
        action = ":VimwikiIndex",
        section = "Notes",
      },
      {
        name = "d    Today's Diary",
        action = ":VimwikiMakeDiaryNote",
        section = "Notes",
      },
      -- 工具
      {
        name = "t    Terminal",
        action = ':lua require("snacks").terminal.toggle()',
        section = "Tools",
      },
      {
        name = "l  󰋕  Session Load",
        action = ':lua require("mini.sessions").read()',
        section = "Tools",
      },
      -- 系统
      {
        name = "q    Quit",
        action = ":qa",
        section = "System",
      },
    },
    content_hooks = {
      -- 添加 BROWNLU logo（按顺序从顶部开始）
      function(content, _)
        local header = {
          { { type = "empty", string = "" } },
        }
        for _, line in ipairs(logo) do
          table.insert(header, { { type = "empty", string = "    " .. line } })
        end
        for i = #header, 1, -1 do
          table.insert(content, 1, header[i])
        end
        return content
      end,
      -- 添加一言格言
      function(content, _)
        local h_ok, h = pcall(require, "config.hitokoto")
        if h_ok then
          table.insert(content, { { type = "empty", string = "" } })
          table.insert(content, { { type = "empty", string = "    " .. h.dashboard_text() } })
        end
        return content
      end,
      st.gen_hook.aligning("center", "center"),
      st.gen_hook.adding_bullet(),
      st.gen_hook.indexing("all", { "Search", "Projects", "Notes", "Tools", "System" }),
      st.gen_hook.padding(1, 1),
    },
  })
end

-- ====== 状态栏 (mini.statusline) ======
local sl_ok, sl = pcall(require, "mini.statusline")
if sl_ok then
  sl.setup({
    use_icons = true,
    set_vim_settings = false,
  })
end

-- ====== 快捷键提示 (which-key) ======
local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
  wk.setup({
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = false },
    },
  })
end

-- ====== 彩色窗口分隔线 ======
local ws_ok, ws = pcall(require, "colorful-winsep")
if ws_ok then
  ws.setup({})
end

-- ====== 光标动画 (smear-cursor) ======
-- 延后 setup：纯视觉效果，约 20ms，启动完成后再加载
vim.schedule(function()
  local smear_ok, smear = pcall(require, "smear_cursor")
  if smear_ok then
    smear.setup({
      stiffness = 0.7,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
    })
  end
end)
