-- 启动页：恢复原 BROWNLU 字符画 + 一言 + 个人快捷入口
-- （LazyVim 默认是 snacks dashboard，这里替换 header 和按键列表）

return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      local logo = {
        "██████╗ ██████╗  ██████╗ ██╗    ██╗███╗   ██╗██╗     ██╗   ██╗",
        "██╔══██╗██╔══██╗██╔═══██╗██║    ██║████╗  ██║██║     ██║   ██║",
        "██████╔╝██████╔╝██║   ██║██║ █╗ ██║██╔██╗ ██║██║     ██║   ██║",
        "██╔══██╗██╔══██╗██║   ██║██║███╗██║██║╚██╗██║██║     ██║   ██║",
        "██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗╚██████╔╝",
        "╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝",
      }

      local header = { table.concat(logo, "\n"), "" }
      -- 一言（缓存命中即格言；未命中先显示占位，异步刷新见 config/hitokoto.lua）
      local h_ok, h = pcall(require, "config.hitokoto")
      if h_ok then
        table.insert(header, h.dashboard_text())
      end

      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = table.concat(header, "\n")

      -- stylua: ignore
      opts.dashboard.preset.keys = {
        { icon = " ", key = "f", desc = "Find File",       action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File",        action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text",       action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent Files",    action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "d", desc = "Dotfiles (chezmoi)", action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.expand('~/.local/share/chezmoi') })" },
        { icon = " ", key = "w", desc = "Vimwiki",         action = ":VimwikiIndex" },
        { icon = " ", key = "t", desc = "Terminal",        action = ":lua Snacks.terminal()" },
        { icon = " ", key = "s", desc = "Restore Session", section = "session" },
        { icon = " ", key = "x", desc = "Lazy Extras",     action = ":LazyExtras" },
        { icon = " ", key = "l", desc = "Lazy",            action = ":Lazy" },
        { icon = " ", key = "q", desc = "Quit",            action = ":qa" },
      }
    end,
  },
}
