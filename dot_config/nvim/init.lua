-- init.lua — Neovim 配置入口
-- 加载顺序严格按依赖关系排列

require('config.plugins')      -- 1. 插件声明 + 安装 + 基础配置（主题、treesitter 等）
require('config.options')      -- 2. 全局选项（不依赖插件）
require('config.keymaps')      -- 3. 快捷键映射
require('config.autocmds')     -- 4. 自动命令
require('config.lsp')          -- 5. Mason + LSP 配置
require('config.completion')   -- 6. blink.cmp 补全
require('config.agent')        -- 7. opencode.nvim AI Agent
