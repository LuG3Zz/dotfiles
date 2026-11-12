-- lua/config/plugins/tools.lua — 工具与会话
-- session 管理 / AsyncRun + AsyncTasks / chezmoi 集成
-- 其它说明：
--   fcitx.nvim       输入法自动切换（packadd 即可，无需 setup）
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

-- ====== chezmoi 模板编辑 (chezmoi-template.nvim) ======
-- 直接编辑 ~/.local/share/chezmoi 源文件，编辑器变成 chezmoi-aware：
--   - gotmpl 高亮 + 目标语言 treesitter 注入（解析器已手动安装）
--   - 写入时模板诊断；:Chezmoi preview 实时渲染预览
--   - {{ }} 内 blink 补全（数据键/模板函数）；:Chezmoi pick 用 mini.pick
--   - apply-on-save 按 buffer target 精确 apply，取代 autocmds.lua 的旧 autocmd
local ctm_ok, ctm = pcall(require, "chezmoi-template")
if ctm_ok then
  ctm.setup({
    apply = { force = true },      -- 跳过 chezmoi 对已修改目标的交互确认
    picker = { backend = "mini" }, -- 显式用 mini.pick（与本配置一致）
  })
end
