-- lua/config/plugins/navigation.lua — 搜索、文件浏览与代码导航
-- mini.pick / mini.icons / grug-far / oil / aerial / dropbar

-- ====== 文件搜索及图标（mini.pick + mini.icons） ======
local pick_ok, pick = pcall(require, "mini.pick")
local icons_ok, icons = pcall(require, "mini.icons")
if icons_ok then
  icons.setup({})
end
if pick_ok then
  pick.setup({
    source = { show_icons = icons_ok },
    window = {
      config = {
        border = "rounded",
      },
    },
    mappings = {
      delete_buffer = {
        char = "D",
        func = function()
          local current = pick.get_picker_matches().current
          if current then
            pcall(vim.api.nvim_buf_delete, current.bufnr, {})
          end
        end,
      },
    },
  })
end

-- ====== 项目级搜索替换 (grug-far) ======
local gf_ok, grug_far = pcall(require, "grug-far")
if gf_ok then
  grug_far.setup({})
end

-- ====== 文件浏览 ======
local oil_ok, oil = pcall(require, "oil")
if oil_ok then
  oil.setup({
    default_file_explorer = true,
    preview_win = {
      update_on_cursor_moved = true,
      preview_method = "fast_scratch",
      win_options = {
        winhl = "Normal:NormalFloat",
      },
    },
    float = {
      max_width = 0.6,
      max_height = 0.8,
      border = "rounded",
      preview_split = "auto",
    },
    keymaps = {
      ["q"] = "actions.close",
      ["<C-h>"] = false,
      ["<M-h>"] = "actions.select_split",
    },
  })
end

-- ====== 代码大纲 (aerial) ======
local aerial_ok, aerial = pcall(require, "aerial")
if aerial_ok then
  aerial.setup({
    -- 右侧纵向分割窗口
    layout = { width = 35, default_direction = "prefer_right" },
    -- 显示所有符号（函数、变量、类等）
    filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Method",
      "Struct",
      "Variable",
    },
    -- 关闭其他大纲视图（单例模式）
    close_behavior = "auto",
    -- 使用优先级：LSP > Treesitter
    sources = { "lsp", "treesitter" },
  })
end

-- ====== 代码结构导航栏 (dropbar) ======
local dropbar_ok, dropbar = pcall(require, "dropbar")
if dropbar_ok then
  dropbar.setup({
    bar = {
      sources = function(buf, _)
        -- 终端缓冲区不显示 winbar
        if vim.bo[buf].buftype == "terminal" then
          return {}
        end
        local sources = require("dropbar.sources")
        local utils = require("dropbar.utils")
        return {
          utils.source.fallback({ sources.lsp, sources.treesitter, sources.path }),
        }
      end,
      truncate = true,
    },
  })
end
