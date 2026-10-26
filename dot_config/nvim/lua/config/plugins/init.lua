-- lua/config/plugins/init.lua — 插件注册与加载入口
-- 职责：
--   1. vim.pack.add() 注册全部插件（只登记/安装，不进入 rtp）
--   2. 决定哪些插件在启动时加载（packadd），哪些懒加载
--   3. 按功能模块调度各插件的 setup
-- 具体配置见同目录下按功能拆分的模块。

-- Helper: 返回完整 GitHub URL
local gh = function(repo)
  return "https://github.com/" .. repo
end

-- 注册所有插件（已在磁盘上，仅快速注册 + 生成 lock 文件）
vim.pack.add({
  -- 主题 / 界面基础
  gh("ellisonleao/gruvbox.nvim"),
  gh("catppuccin/nvim"),
  gh("nvim-treesitter/nvim-treesitter"),
  -- mini 系列
  gh("nvim-mini/mini.pick"),
  gh("nvim-mini/mini.ai"),
  gh("nvim-mini/mini.surround"),
  gh("nvim-mini/mini.icons"),
  gh("nvim-mini/mini.starter"),
  gh("nvim-mini/mini.cursorword"),
  gh("nvim-mini/mini.sessions"),
  gh("nvim-mini/mini.move"),
  gh("nvim-mini/mini.trailspace"),
  gh("nvim-mini/mini.hipatterns"),
  gh("nvim-mini/mini.comment"),
  gh("nvim-mini/mini.statusline"),
  gh("nvim-mini/mini.pairs"),
  -- 编辑 / 导航
  gh("sustech-data/wildfire.nvim"),
  gh("Eandrju/cellular-automaton.nvim"),
  gh("monaqa/dial.nvim"),
  gh("nvim-zh/colorful-winsep.nvim"),
  gh("folke/snacks.nvim"),
  gh("HiPhish/rainbow-delimiters.nvim"),
  gh("Bekaboo/dropbar.nvim"),
  gh("stevearc/oil.nvim"),
  gh("stevearc/aerial.nvim"),
  gh("folke/which-key.nvim"),
  { src = gh("kkew3/jieba.vim"), branch = "release" },
  gh("yaocccc/visual-multi.nvim"),
  gh("mbbill/undotree"),
  gh("kevinhwang91/nvim-ufo"),
  gh("kevinhwang91/promise-async"),
  gh("folke/flash.nvim"),
  -- 补全 / LSP
  gh("saghen/blink.lib"),
  gh("saghen/blink.cmp"),
  gh("mason-org/mason.nvim"),
  gh("mason-org/mason-lspconfig.nvim"),
  gh("neovim/nvim-lspconfig"),
  -- 搜索 / Git
  gh("MagicDuck/grug-far.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  -- 语言 / 文档
  gh("OXY2DEV/markview.nvim"),
  gh("vimwiki/vimwiki"),
  gh("R-nvim/R.nvim"),
  gh("rafamadriz/friendly-snippets"),
  -- AI
  gh("milanglacier/minuet-ai.nvim"),
  -- 工具 / 集成
  gh("alker0/chezmoi.vim"),
  gh("h-hg/fcitx.nvim"),
  gh("skywind3000/asyncrun.vim"),
  gh("skywind3000/asynctasks.vim"),
  gh("sphamba/smear-cursor.nvim"),
  gh("rachartier/tiny-cmdline.nvim"),
}, {
  -- 关键：vim.pack.add() 默认在 init 阶段等价于执行 `:packadd!`，会把所有插件
  -- 加进 rtp；随后 `packloadall` 照样 source 每个 plugin/ 文件，懒加载完全失效。
  -- 用 no-op load 让插件只做“登记/安装”，不进 rtp；真正加载交给下面显式的
  -- packadd 列表（dial / R.nvim / minuet / vimwiki 故意不在此列表，首次使用时加载）。
  load = function() end,
})

-- ====== 启动时加载的插件（opt/ 目录需 packadd） ======
-- 顺序有依赖：chezmoi.vim 需在 filetype/syntax 之前加载，放最前
vim.cmd.packadd("chezmoi.vim")
vim.cmd.packadd("gruvbox.nvim")
vim.cmd.packadd("nvim") -- catppuccin/nvim
vim.cmd.packadd("nvim-treesitter")
vim.cmd.packadd("mini.pick")
vim.cmd.packadd("mini.ai")
vim.cmd.packadd("mini.surround")
vim.cmd.packadd("mini.icons")
vim.cmd.packadd("mini.starter")
vim.cmd.packadd("mini.cursorword")
vim.cmd.packadd("mini.sessions")
vim.cmd.packadd("mini.move")
vim.cmd.packadd("mini.trailspace")
vim.cmd.packadd("mini.hipatterns")
vim.cmd.packadd("wildfire.nvim")
vim.cmd.packadd("cellular-automaton.nvim")
vim.cmd.packadd("mini.comment")
-- dial.nvim 懒加载：见 config/dial.lua（首次 <C-a>/<C-x> 时 packadd）
vim.cmd.packadd("colorful-winsep.nvim")
vim.cmd.packadd("snacks.nvim")
vim.cmd.packadd("mini.statusline")
vim.cmd.packadd("rainbow-delimiters.nvim")
vim.cmd.packadd("dropbar.nvim")
vim.cmd.packadd("oil.nvim")
vim.cmd.packadd("aerial.nvim")
vim.cmd.packadd("blink.lib") -- blink.cmp 依赖
vim.cmd.packadd("blink.cmp")
-- jieba.vim 需要先设配置再 packadd，否则 g: 变量读不到
vim.g.jieba_vim_lazy = 1
vim.g.jieba_vim_keymap = 1
vim.cmd.packadd("jieba.vim")
vim.cmd.packadd("visual-multi.nvim")
vim.cmd.packadd("which-key.nvim")
vim.cmd.packadd("mason.nvim")
vim.cmd.packadd("mason-lspconfig.nvim")
vim.cmd.packadd("nvim-lspconfig")
vim.cmd.packadd("mini.pairs")
vim.cmd.packadd("flash.nvim")
vim.cmd.packadd("undotree")
vim.cmd.packadd("promise-async")
vim.cmd.packadd("nvim-ufo")
vim.cmd.packadd("gitsigns.nvim")
vim.cmd.packadd("friendly-snippets")
vim.cmd.packadd("smear-cursor.nvim")
-- tiny-cmdline 也需要先设配置再 packadd
vim.g.tiny_cmdline = {
  width = { value = "70%" },
  prompt_prefix = " ",
  position = { y = "1%" },
  native_types = {},
}
vim.cmd.packadd("tiny-cmdline.nvim")
vim.cmd.packadd("fcitx.nvim")
vim.cmd.packadd("asyncrun.vim")
vim.cmd.packadd("asynctasks.vim")
vim.cmd.packadd("markview.nvim")
vim.cmd.packadd("grug-far.nvim")
-- 懒加载（不在上面加载）：
--   dial.nvim      -> config/dial.lua（首次 <C-a>/<C-x>）
--   R.nvim         -> config/plugins/languages.lua（打开 R 文件）
--   vimwiki        -> config/plugins/languages.lua（VimEnter 后）
--   minuet-ai      -> config/plugins/ai.lua（启动完成后）

-- ====== 按功能模块调度 ======
require("config.plugins.ui")         -- 主题 / 启动页 / snacks / 状态栏 / which-key
require("config.plugins.editing")    -- 文本对象 / 环绕 / 注释 / 移动 / 高亮 / flash
require("config.plugins.navigation") -- 搜索 / 文件浏览 / 大纲 / winbar
require("config.plugins.treesitter") -- 语法高亮 / 括号
require("config.plugins.git")        -- gitsigns
require("config.plugins.ai")         -- minuet（DeepSeek ghost text）
require("config.plugins.languages")  -- R / markdown / vimwiki
require("config.plugins.tools")      -- session / asynctasks / 其它集成
