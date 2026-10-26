-- lua/config/options.lua — Neovim 全局选项

vim.opt.number = true          -- 行号
vim.opt.relativenumber = true  -- 相对行号
vim.opt.cursorline = true      -- 高亮当前行

-- ====== PATH: mason 安装的 CLI ======
-- mason.setup 会 prepend 自己的 bin，但它现在延后到启动完成后执行；
-- 这里提前加上，保证 tree-sitter / stylua / shfmt 等工具随时可用
local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
if vim.fn.isdirectory(mason_bin) == 1 and not (vim.env.PATH or ''):find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ':' .. (vim.env.PATH or '')
end

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true       -- 空格代替 tab
vim.opt.softtabstop = 2

vim.opt.wrap = false           -- 不自动折行

vim.opt.ignorecase = true      -- 搜索忽略大小写
vim.opt.smartcase = true       -- 大写输入时区分大小写
vim.opt.incsearch = true       -- 增量搜索
vim.opt.hlsearch = true        -- 高亮搜索结果

vim.opt.splitright = true      -- 新窗口在右侧
vim.opt.splitbelow = true      -- 新窗口在下方

vim.opt.termguicolors = true   -- 真彩色

vim.opt.undofile = true        -- 撤销历史持久化
vim.opt.undodir = vim.fn.stdpath('state') .. '/undo'

vim.opt.updatetime = 300       -- 更新延迟（ms）
vim.opt.timeoutlen = 500       -- 键序列超时（ms，按 <leader>r 等第二个键的等待时间）

vim.opt.completeopt = 'menuone,noselect'  -- 补全行为
vim.opt.pumblend = 10          -- 弹出菜单透明度
vim.opt.pumheight = 10         -- 弹出菜单最大行数
vim.opt.wildoptions = 'pum'    -- cmdline 补全弹出菜单（而非滚屏）
vim.opt.wildmode = 'longest:full,full'  -- 先补最长公共前缀，再列出候选
vim.opt.cmdheight = 0           -- 实验性: 隐藏底部命令行，按 : 时弹出单行输入

-- ====== 编辑效率相关 ======
vim.opt.clipboard = 'unnamedplus'  -- y/p 直接读写系统剪贴板（Wayland 走 wl-copy）
vim.opt.inccommand = 'split'       -- :s/old/new/g 实时预览所有替换位置
vim.opt.jumpoptions = 'stack'      -- <C-o>/<C-i> 按栈式语义跳转，来回不绕圈
vim.opt.winborder = 'rounded'      -- 所有浮动窗口统一圆角（hover/诊断/签名等）
vim.opt.shortmess:append('c')      -- 减少补全相关的 hit-enter 提示

vim.opt.mouse = 'a'            -- 启用鼠标

vim.opt.signcolumn = 'yes'     -- 始终显示符号列
vim.opt.showmode = true        -- 显示模式（含录制宏提示 "recording @a"）
vim.opt.conceallevel = 2       -- Markdown/语法特性需要 ≥1

-- ====== 编码设置 ======
vim.opt.fileencoding = 'utf-8'             -- 新文件 UTF-8
vim.opt.fileencodings = 'utf-8,gbk,gb2312,gb18030,big5,latin1'  -- 读取时自动检测编码（中文兼容）

-- 隐藏缩进标记（0.12+ 内置）
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- ====== 取自 Duy NG 参考配置 ======

-- 滚动上下文
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- 智能缩进
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.shiftround = true

-- 保持视图位置
vim.opt.splitkeep = 'screen'

-- 行为增强
vim.opt.autoread = true          -- 0.12+: 文件系统监视器实时检测外部更改（不再依赖 FocusGained）
vim.opt.confirm = true          -- 退出时确认保存
vim.opt.hidden = true           -- 允许隐藏 buffer
vim.opt.showmatch = true        -- 输入括号时短暂高亮匹配
vim.opt.matchtime = 2           -- 匹配高亮时长
vim.opt.backspace = 'indent,eol,start'
vim.opt.virtualedit = 'block'   -- 可视块模式可移出文本末尾

-- 搜索增强
vim.opt.grepprg = 'rg --vimgrep'
vim.opt.grepformat = '%f:%l:%c:%m'

-- 单词构成（破折号视为单词一部分）
vim.opt.iskeyword:append('-')
vim.opt.path:append('**')

-- 性能与显示
vim.opt.synmaxcol = 300         -- 大文件截断语法高亮
vim.opt.smoothscroll = true     -- 平滑滚动
vim.opt.foldlevel = 99           -- 默认展开所有折叠（由 nvim-ufo 接管）
vim.opt.fillchars:append({
  eob = ' ',                     -- 文件末尾空白行用空格
  diff = '╱',
  fold = ' ',
  foldopen = '▾',
  foldclose = '▸',
  foldsep = ' ',
})
