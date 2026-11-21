-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- 这里只放个人习惯；LazyVim 已覆盖的（补全回车、quickfix <leader>xq、
-- grug-far <leader>sr、拼写 <leader>us 等）不用重复定义。

local map = vim.keymap.set

-- ====== Cargo / Rust（asynctasks，定义见 plugins/tools.lua 的 lazy keys）======
-- <leader>Cc = file-build：只编译当前文件，报错进 quickfix（]q/[q 浏览）
map("n", "<leader>Cc", "<cmd>AsyncTask file-build<CR>", { desc = "Compile current file" })

-- ====== 撤销树 ======
map("n", "<leader>uu", "<cmd>UndotreeToggle<CR>", { desc = "Undo tree" })

-- ====== 翻译 ======
map({ "n", "x" }, "<leader>kd", function()
  require("config.translate").show()
end, { desc = "Translate word" })

-- ====== 主题切换（持久化，gruvbox ⇆ catppuccin）======
map("n", "<leader>uC", function()
  require("config.theme").toggle()
end, { desc = "Toggle theme" })

-- ====== Vimwiki ======
map("n", "<leader>W", "<cmd>VimwikiIndex<CR>", { desc = "Vimwiki index" })

-- ====== 折叠导航（nvim-ufo）======
map("n", "zv", "zMzvzz", { desc = "Close folds except current" })
map("n", "zj", "zcjzOzz", { desc = "Open next fold" })
map("n", "zk", "zckzOzz", { desc = "Open previous fold" })

-- ====== 细胞自动机 ======
map("n", "<leader>zr", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "Cellular: rain" })
map("n", "<leader>zg", "<cmd>CellularAutomaton game_of_life<CR>", { desc = "Cellular: game of life" })
map("n", "<leader>zs", "<cmd>CellularAutomaton scramble<CR>", { desc = "Cellular: scramble" })

-- ====== 终端模式窗口导航 ======
map("t", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Terminal: left window" })
map("t", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Terminal: lower window" })
map("t", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Terminal: upper window" })
map("t", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Terminal: right window" })
-- 用 <C-\><C-\> 退出终端模式（避免与 Zsh vi-mode 的 <Esc> 冲突）
map("t", "<C-\\><C-\\>", "<C-\\><C-n>", { desc = "Terminal: normal mode" })

-- ====== insert 模式自然停顿处分段 undo ======
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")
