-- lua/config/plugins/git.lua — Git 集成
-- gitsigns.nvim（lazygit 走 snacks，配置见 ui.lua / keymaps.lua）

-- ====== Git 标记 (gitsigns) ======
local gs_ok, gs = pcall(require, "gitsigns")
if gs_ok then
  gs.setup({
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    current_line_blame = false, -- 用 <leader>gb 触发
    signcolumn = true,
    numhl = false,
    watch_gitdir = { interval = 1000 },
  })
end
