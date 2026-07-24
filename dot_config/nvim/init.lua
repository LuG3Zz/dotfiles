-- init.lua — Neovim 配置入口
-- 加载顺序严格按依赖关系排列

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.plugins')      -- 1. 插件声明 + 安装 + 基础配置（主题、treesitter 等）
require('config.options')      -- 2. 全局选项（不依赖插件）
require('config.keymaps')      -- 3. 快捷键映射
require('config.diagnostics')   -- 4. 诊断显示与导航
require('config.autocmds')     -- 5. 自动命令
require('config.lsp')          -- 6. Mason + LSP 配置
require('config.completion')   -- 7. blink.cmp 补全
require('config.agent')        -- 8. opencode.nvim AI Agent
