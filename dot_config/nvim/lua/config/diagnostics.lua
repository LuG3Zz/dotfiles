-- lua/config/diagnostics.lua — 诊断（错误/警告）视觉与导航配置
-- 参考：Duy NG https://tduyng.com/blog/neovim-basic-setup/

local map = vim.keymap.set
local sev = vim.diagnostic.severity

-- ====== 行级诊断背景色（跟随主题） ======
-- 用当前主题的诊断前景色压暗后作为行背景，切换主题时自动重建；
-- 避免写死 gruvbox 色值（切到 catppuccin 时违和）。
local line_hl = {
  [sev.ERROR] = 'DiagnosticErrorLine',
  [sev.WARN]  = 'DiagnosticWarnLine',
  [sev.INFO]  = 'DiagnosticInfoLine',
  [sev.HINT]  = 'DiagnosticHintLine',
}
local sev_fg_hl = {
  [sev.ERROR] = 'DiagnosticError',
  [sev.WARN]  = 'DiagnosticWarn',
  [sev.INFO]  = 'DiagnosticInfo',
  [sev.HINT]  = 'DiagnosticHint',
}

local function darken(color, factor)
  local r = math.floor(color / 65536) % 256
  local g = math.floor(color / 256) % 256
  local b = color % 256
  return math.floor(r * factor) * 65536 + math.floor(g * factor) * 256 + math.floor(b * factor)
end

local function refresh_line_hl()
  for severity, group in pairs(line_hl) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = sev_fg_hl[severity], link = false })
    local fg = ok and hl and hl.fg
    if type(fg) == 'number' then
      vim.api.nvim_set_hl(0, group, { bg = darken(fg, 0.22) })
    end
  end
end

refresh_line_hl()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('UserDiagnosticLineHl', { clear = true }),
  callback = refresh_line_hl,
})

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
  -- Neovim 0.11+ 行高亮（颜色由上方 refresh_line_hl 按主题生成）
  linehl = line_hl,
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

-- ====== Inlay hints 样式 ====
-- 可选方案：
--   方案 A: 斜体 + 浅色（推荐，与代码区分明显）
--   方案 B: 更深色（更低调）
--   方案 C: 恢复默认（注释掉即可）
--
-- 当前使用方案 A

-- 方案 A: 斜体 + 浅灰
vim.api.nvim_set_hl(0, 'LspInlayHint', { fg = '#6C7086', italic = true })

-- 方案 B: 更深色（取消注释即可替换）
-- vim.api.nvim_set_hl(0, 'LspInlayHint', { fg = '#585B70' })