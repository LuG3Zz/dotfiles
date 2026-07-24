-- lua/config/options.lua — Neovim 全局选项

vim.opt.number = true          -- 行号
vim.opt.relativenumber = true  -- 相对行号
vim.opt.cursorline = true      -- 高亮当前行

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
vim.opt.timeoutlen = 300       -- 键序列超时

vim.opt.completeopt = 'menuone,noselect'  -- 补全行为
vim.opt.pumblend = 10          -- 弹出菜单透明度
vim.opt.pumheight = 10         -- 弹出菜单最大行数

vim.opt.mouse = 'a'            -- 启用鼠标

vim.opt.signcolumn = 'yes'     -- 始终显示符号列
vim.opt.showmode = false       -- 状态行已显示模式，无需重复

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
vim.opt.foldmethod = 'expr'      -- Treesitter 语法折叠
vim.opt.foldlevel = 99           -- 默认展开所有折叠
vim.opt.fillchars:append({
  eob = ' ',                     -- 文件末尾空白行用空格
  diff = '╱',
  fold = ' ',
  foldopen = '▾',
  foldclose = '▸',
  foldsep = ' ',
})
