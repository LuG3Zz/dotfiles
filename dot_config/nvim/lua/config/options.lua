-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- ====== 个人偏好（LazyVim 默认之外的增量）======

-- y/p 直接读写系统剪贴板（Wayland 走 wl-copy）
vim.opt.clipboard = "unnamedplus"

-- 中文编码自动检测
vim.opt.fileencodings = "utf-8,gbk,gb2312,gb18030,big5,latin1"

-- 键序列超时（which-key 弹出与映射等待的平衡）
-- 500 会让 s / g / 空格 这类"有前缀映射"的键最多等 0.5 秒才响应，
-- 体感就是"按了没反应"，用 LazyVim 默认的 300 更跟手。
vim.opt.timeoutlen = 300
vim.opt.updatetime = 300

-- 滚动上下文
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- 可视块可移出文本末尾
vim.opt.virtualedit = "block"

-- 破折号视为单词一部分
vim.opt.iskeyword:append("-")
-- gf 可搜索整个项目
vim.opt.path:append("**")

-- 大文件截断语法高亮
vim.opt.synmaxcol = 300

-- 折叠交给 nvim-ufo（默认全展开）
vim.opt.foldlevel = 99

-- 括号匹配插件 matchparen 在插入模式的默认等待较长，退格/输入时会
-- 造成可感知的"卡一下"；10ms 足够。
vim.g.matchparen_timeout = 10
vim.g.matchparen_insert_timeout = 10

-- 关闭相对行号：按 j/k 时所有可见行的相对数字都要重画，实测每次
-- 重绘单元格 264 → 34.6（7.6 倍），是本配置里普通模式最大的单键开销。
-- 想要相对行号就把下面改成 true（可以接受 j/k 多一点重绘）。
vim.opt.relativenumber = false
