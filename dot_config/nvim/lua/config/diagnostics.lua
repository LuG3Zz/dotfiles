-- lua/config/diagnostics.lua — 诊断（错误/警告）视觉与导航配置
-- 参考：Duy NG https://tduyng.com/blog/neovim-basic-setup/

local map = vim.keymap.set
local sev = vim.diagnostic.severity

-- ====== 行级诊断背景色（柔和，不刺眼） ======
vim.api.nvim_set_hl(0, 'DiagnosticErrorLine', { bg = '#51202A', blend = 20 })
vim.api.nvim_set_hl(0, 'DiagnosticWarnLine',  { bg = '#3B3B1B', blend = 15 })
vim.api.nvim_set_hl(0, 'DiagnosticInfoLine',  { bg = '#1F3342', blend = 10 })
vim.api.nvim_set_hl(0, 'DiagnosticHintLine',  { bg = '#1E2E1E', blend = 10 })

-- ====== 主配置 ======
vim.diagnostic.config({
  underline = true,
  severity_sort = true,
  update_in_insert = false,       -- 输入时不更新，减少闪烁
  float = {
    border = 'rounded',
    source = true,                 -- 显示诊断来源
  },
  signs = {
    text = {
      [sev.ERROR] = '󰅙 ',         -- 红色 X 图标
      [sev.WARN]  = '󰀪 ',         -- 黄色警告图标
      [sev.INFO]  = '󰋼 ',         -- 蓝色信息图标
      [sev.HINT]  = '󰌵 ',         -- 灰色提示图标
    },
  },
  virtual_text = {
    spacing = 4,
    source = 'if_many',
    prefix = '●',
  },
  -- Neovim 0.11+ 行高亮
  linehl = {
    [sev.ERROR] = 'DiagnosticErrorLine',
    [sev.WARN]  = 'DiagnosticWarnLine',
    [sev.INFO]  = 'DiagnosticInfoLine',
    [sev.HINT]  = 'DiagnosticHintLine',
  },
})

-- ====== 诊断导航快捷键 ======

-- 辅助函数：跳转到指定级别诊断
local diagnostic_goto = function(next, severity)
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    vim.diagnostic.jump({ count = next and 1 or -1, float = true, severity = severity })
  end
end

-- 通用诊断导航（已有关键映射 [d / ]d）
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Show line diagnostics' })
map('n', ']d', diagnostic_goto(true),  { desc = 'Next diagnostic' })
map('n', '[d', diagnostic_goto(false), { desc = 'Prev diagnostic' })

-- 按级别导航：错误优先，警告次之
map('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next error' })
map('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev error' })
map('n', ']w', diagnostic_goto(true, 'WARN'),  { desc = 'Next warning' })
map('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev warning' })




