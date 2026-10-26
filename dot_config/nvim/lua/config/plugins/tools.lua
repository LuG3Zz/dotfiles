-- lua/config/plugins/tools.lua — 工具与会话
-- session 管理 / AsyncRun + AsyncTasks
-- 其它说明：
--   fcitx.nvim       输入法自动切换（packadd 即可，无需 setup）
--   chezmoi.vim      chezmoi 源文件语法（packadd 即可）
--   cellular-automaton.nvim / translate / tiny-cmdline 由 keymaps.lua 触发或 init 配置

-- ====== Session 管理 ======
local s_ok, s = pcall(require, "mini.sessions")
if s_ok then
  s.setup({
    autoread = false,
    autowrite = false,
    directory = vim.fn.stdpath("state") .. "/sessions",
  })
end

-- 自动保存开关
vim.g.autosave_session = false

-- ====== AsyncRun + AsyncTasks 配置 ======
vim.g.asyncrun_open = 0 -- 不自动打开 quickfix（由 asynctasks 控制）
vim.g.asynctasks_term_pos = "bottom" -- 终端模式默认位置
vim.g.asynctasks_term_rows = 12 -- 终端高度
vim.g.asynctasks_term_reuse = 1 -- 复用已有终端窗口
