-- 工具与集成：jieba / asynctasks / chezmoi 模板
-- （输入法自动切换见 lua/config/ime.lua：异步调用 fcitx5-remote）

return {

  -- ====== 中文分词（g: 变量必须在插件加载前设置）======
  -- 注意：release 分支不含预编译 .so，首次安装需本地编译（国内用 rsproxy 镜像）：
  --   cd ~/.local/share/nvim/lazy/jieba.vim
  --   PATH=<cargo 镜像 wrapper>:$PATH JIEBA_VIM_BUILD_FROM_SOURCE=1 \
  --     JIEBA_VIM_INSTALL_NVIM=1 bash build.sh
  -- 或直接 cargo --config 'source.crates-io.replace-with="rsproxy"' ...
  {
    "kkew3/jieba.vim",
    branch = "release",
    init = function()
      vim.g.jieba_vim_lazy = 1
      vim.g.jieba_vim_keymap = 1
    end,
    event = "VeryLazy",
  },

  -- ====== 异步任务（tasks.ini 在本配置目录）======
  {
    "skywind3000/asyncrun.vim",
    cmd = { "AsyncRun", "AsyncStop" },
  },
  {
    "skywind3000/asynctasks.vim",
    cmd = { "AsyncTask" },
    init = function()
      vim.g.asyncrun_open = 0 -- 不自动打开 quickfix
      vim.g.asynctasks_term_pos = "bottom"
      vim.g.asynctasks_term_rows = 12
      vim.g.asynctasks_term_reuse = 1
    end,
    keys = {
      { "<leader>X", "<cmd>AsyncTask file-run<cr>", desc = "Run file" },
      { "<leader>Cb", "<cmd>AsyncTask cargo-build<cr>", desc = "Cargo build" },
      { "<leader>Ct", "<cmd>AsyncTask cargo-test<cr>", desc = "Cargo test" },
      { "<leader>Ck", "<cmd>AsyncTask cargo-check<cr>", desc = "Cargo check" },
      { "<leader>Cl", "<cmd>AsyncTask cargo-clippy<cr>", desc = "Cargo clippy" },
    },
  },

  -- ====== chezmoi 模板编辑（直接编辑源文件，写入时自动 apply）======
  -- blink 补全源：{{ }} 内的数据键/模板函数/块片段，仅 gotmpl 生效
  {
    "saghen/blink.cmp",
    optional = true,
    -- stylua: ignore
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      -- LazyVim/blink 默认 min_keyword_length=0：每敲一个字符都向 LSP 发
      -- 补全请求（clangd 每次都要重建 sema context），是 C 输入卡顿主因之一。
      opts.sources.min_keyword_length = 2
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      opts.sources.per_filetype.gotmpl = vim.list_extend(
        vim.deepcopy(opts.sources.per_filetype.gotmpl or { "lsp", "path", "snippets", "buffer" }),
        { "chezmoi" }
      )
      opts.sources.providers = vim.tbl_extend("force", opts.sources.providers or {}, {
        chezmoi = { name = "chezmoi", module = "chezmoi-template.blink" },
      })

      -- 降低每击键的渲染开销（clangd 本身 5-7ms，瓶颈在菜单 UI）：
      -- max_items 200 -> 20：少渲染 10 倍候选
      opts.completion = opts.completion or {}
      opts.completion.list = vim.tbl_extend("force", opts.completion.list or {}, { max_items = 20 })
      -- 菜单防抖 100ms：连续打字时不反复弹/重绘
      opts.completion.menu = vim.tbl_extend("force", opts.completion.menu or {}, { auto_show_delay_ms = 100 })
      -- 文档浮窗延迟 800ms：快速输入时不触发 completionItem/resolve + 浮窗重绘
      opts.completion.documentation =
        vim.tbl_extend("force", opts.completion.documentation or {}, { auto_show_delay_ms = 800 })
      return opts
    end,
  },
  {
    "dpezto/chezmoi-template.nvim",
    event = "VeryLazy",
    config = function()
      require("chezmoi-template").setup({
        apply = { force = true }, -- 跳过 chezmoi 对已修改目标的确认
        -- picker 自动探测，用 LazyVim 的 snacks.picker
      })
    end,
    keys = {
      { "<leader>cz", "<cmd>Chezmoi preview<cr>", desc = "Chezmoi preview" },
      { "<leader>cp", "<cmd>Chezmoi pick<cr>", desc = "Chezmoi pick (source files)" },
    },
  },

  -- ====== 文件浏览（oil，覆盖 LazyVim 默认 <leader>e）======
  {
    "stevearc/oil.nvim",
    keys = {
      {
        "<leader>e",
        function()
          require("oil").open_float()
          vim.defer_fn(function()
            if require("oil").get_cursor_entry() then
              require("oil").open_preview({})
            end
          end, 400)
        end,
        desc = "File explorer (oil, float + preview)",
      },
    },
    opts = {
      default_file_explorer = true,
      preview_win = {
        update_on_cursor_moved = true,
        preview_method = "fast_scratch",
        win_options = { winhl = "Normal:NormalFloat" },
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
    },
  },

  -- ====== 代码大纲 ======
  {
    "stevearc/aerial.nvim",
    keys = {
      { "<leader>O", "<cmd>AerialToggle!<cr>", desc = "Toggle outline" },
    },
    opts = {
      layout = { width = 35, default_direction = "prefer_right" },
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
      close_behavior = "auto",
      sources = { "lsp", "treesitter" },
    },
  },

  -- ====== winbar 代码导航 ======
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- winbar 更新策略：去掉 TextChanged，并把 debounce 加大。
      -- 原来每次击键（含退格）都会触发一次 winbar 更新，且 sources 以
      -- LSP documentSymbols 优先 → 异步回应 + 重绘，表现为"删字卡一下"。
      bar = {
        update_debounce = 250,
        update_events = {
          win = { "CursorMoved", "WinResized" },
          buf = { "FileChangedShellPost", "ModeChanged" },
          global = { "DirChanged", "VimResized" },
        },
        -- 栏内容来源：treesitter 优先、LSP 兜底（减少每次更新的 documentSymbols 请求）
        sources = function(buf, _)
          if vim.bo[buf].buftype == "terminal" then
            return {}
          end
          local sources = require("dropbar.sources")
          local utils = require("dropbar.utils")
          return { utils.source.fallback({ sources.treesitter, sources.path, sources.lsp }) }
        end,
      },
    },
  },
}
