-- 编辑增强：LazyVim 之外的补充（mini.ai/pairs/comment、surround、dial
-- 由 LazyVim 核心/extra 提供，这里只放缺的）

return {
  -- ====== 选区火焰扩散 ======
  {
    "sustech-data/wildfire.nvim",
    event = "VeryLazy",
    opts = {
      filetype_exclude = { "qf", "snacks_dashboard" },
      keymaps = {
        init_selection = "==",
        node_incremental = "==",
        node_decremental = "<BS>",
      },
    },
  },

  -- ====== 多光标 ======
  { "yaocccc/visual-multi.nvim" },

  -- ====== 光标动画 ======
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      stiffness = 0.7,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
      -- 插入模式不做动画：每击键都跑动画帧，叠加上透明度/模糊会明显
      -- 放大输入延迟（默认 smear_insert_mode = true）
      smear_insert_mode = false,
      -- 上下相邻行（j/k）也不做动画：默认 true 时每按一次 j/k 会多画
      -- 2~3 帧（实测 12 次 j：27 帧 → 关掉后 9 帧），在透明终端里就是
      -- 一卡一卡的感觉；大跳转仍有拖影动画
      smear_between_neighbor_lines = false,
    },
  },

  -- ====== 彩色窗口分隔线 ======
  { "nvim-zh/colorful-winsep.nvim", event = { "WinNew" }, opts = {} },

  -- ====== 迷你命令行 ======
  {
    "rachartier/tiny-cmdline.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.tiny_cmdline = {
        width = { value = "70%" },
        prompt_prefix = " ",
        position = { y = "1%" },
        native_types = {},
      }
    end,
  },

  -- ====== 行移动 ======
  {
    "nvim-mini/mini.move",
    opts = {
      mappings = {
        left = "<M-h>",
        right = "<M-l>",
        down = "<M-j>",
        up = "<M-k>",
      },
    },
  },

  -- ====== 行尾空格 ======
  { "nvim-mini/mini.trailspace", event = { "BufReadPost", "BufNewFile" }, opts = {} },

  -- ====== 颜色/模式高亮 ======
  {
    "nvim-mini/mini.hipatterns",
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local hp = require("mini.hipatterns")
      return {
        highlighters = { hex_color = hp.gen_highlighter.hex_color() },
      }
    end,
  },

  -- ====== 光标下单词高亮 ======
  { "nvim-mini/mini.cursorword", event = { "BufReadPost", "BufNewFile" }, opts = {} },

  -- ====== 撤销树 ======
  {
    "mbbill/undotree",
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
    },
  },

  -- ====== 折叠增强 ======
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    init = function()
      vim.o.foldlevel = 99
    end,
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
        local text = vim.fn.getline(lnum):gsub("^%s+", "")
        local suffix = " …  " .. (end_lnum - lnum)
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
        win_config = { border = "rounded", winblend = 12, maxheight = 15 },
      },
    },
  },
  { "kevinhwang91/promise-async", lazy = true },

  -- ====== 细胞自动机 ======
  { "Eandrju/cellular-automaton.nvim", cmd = "CellularAutomaton" },
}
