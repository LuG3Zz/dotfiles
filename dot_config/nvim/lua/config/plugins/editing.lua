-- lua/config/plugins/editing.lua — 编辑增强
-- 文本对象 / 环绕 / 注释 / 括号 / 行移动 / 光标词高亮 / 行尾空格 / 颜色高亮
-- 选区火焰 / 多光标 / flash 跳转 / 撤销树 / 增量改值
-- 注：中文分词（jieba.vim）的 g: 变量在 init.lua 加载段设置（必须先于 packadd）

-- ====== 文本对象增强 ======
local ai_ok, ai = pcall(require, "mini.ai")
if ai_ok then
  ai.setup({})
end

-- ====== 环绕编辑 ======
local surround_ok, surround = pcall(require, "mini.surround")
if surround_ok then
  surround.setup({})
end

-- ====== 光标下单词高亮 ======
local cw_ok, cw = pcall(require, "mini.cursorword")
if cw_ok then
  cw.setup({})
end

-- ====== 行移动增强 ======
local mv_ok, mv = pcall(require, "mini.move")
if mv_ok then
  mv.setup({
    mappings = {
      left = "<M-h>",
      right = "<M-l>",
      down = "<M-j>",
      up = "<M-k>",
    },
  })
end

-- ====== 行尾空格高亮/清除 ======
local ts_ok, ts = pcall(require, "mini.trailspace")
if ts_ok then
  ts.setup({})
end

-- ====== 颜色/模式高亮 ======
local hp_ok, hp = pcall(require, "mini.hipatterns")
if hp_ok then
  hp.setup({
    highlighters = {
      hex_color = hp.gen_highlighter.hex_color(),
    },
  })
  -- 立即禁用 buffer 类型非空的缓冲区
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "snacks_dashboard" then
      vim.b[buf].minihipatterns_disable = true
    end
  end
  -- 新 buffer 创建时提前禁用（在 FileType 事件之前）
  vim.api.nvim_create_autocmd("BufAdd", {
    group = vim.api.nvim_create_augroup("MiniHipatternsDisable", { clear = true }),
    callback = function()
      if vim.bo.buftype ~= "" then
        vim.b.minihipatterns_disable = true
      end
    end,
  })
end

-- ====== 选区火焰扩散 (wildfire) ======
local wf_ok, wf = pcall(require, "wildfire")
if wf_ok then
  wf.setup({
    filetype_exclude = { "qf", "ministarter" },
    keymaps = {
      init_selection = "==",
      node_incremental = "==",
      node_decremental = "<BS>",
    },
  })
end

-- ====== 智能注释 ======
local cm_ok, cm = pcall(require, "mini.comment")
if cm_ok then
  cm.setup({})
end

-- ====== 增量改值增强 (dial.nvim) ======
-- dial 改为懒加载，augends 配置移到了 config/dial.lua 的 ensure() 中
-- （首次按 <C-a>/<C-x> 时加载，避免 ~100ms 启动开销）

-- ====== 自动补全括号/引号 (mini.pairs) ======
local pairs_ok, pairs = pcall(require, "mini.pairs")
if pairs_ok then
  pairs.setup({})
end

-- ====== 增强字符跳转 (f/t) ======
local flash_ok, flash = pcall(require, "flash")
if flash_ok then
  flash.setup({
    modes = {
      char = {
        enabled = true,
        jump_labels = true,
      },
    },
    highlight = {
      backdrop = true,
      groups = { match = "DiffAdd", label = "String" },
    },
  })
end

-- ====== 撤销树浏览 ======
-- mbbill/undotree: `<leader>u` 切换撤销树
-- 已通过 pcall 安全加载，无需额外 setup

-- ====== 多光标 (yaocccc/visual-multi.nvim) ======
-- <C-n> 选词，<C-d> 全选，<C-Up/Down> 行光标，q 跳过

-- ====== 折叠增强 (nvim-ufo) ======
-- 延后到启动完成：require('ufo') 会连锁加载 fold/manager/model 约 45ms，
-- 折叠对首屏不是必需，schedule 后加载不影响体验
vim.schedule(function()
  local ufo_ok, ufo = pcall(require, "ufo")
  if ufo_ok then
    ufo.setup({
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
        local text = vim.fn.getline(lnum):gsub("^%s+", "")
        local suffix = " …  " .. (end_lnum - lnum)
        if vim.fn.strdisplaywidth(text) > width - 6 then
          text = truncate(text, width - 6)
        end
        return {
          { text, "NormalFloat" },
          { suffix, "Comment" },
        }
      end,
      open_fold_hl_timeout = 200,
      preview = {
        win_config = {
          border = "rounded",
          winblend = 12,
          maxheight = 15,
        },
      },
    })
  end
end)
