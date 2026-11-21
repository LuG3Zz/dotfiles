-- 语言与文档：vimwiki / R.nvim / crates / markview / minuet

return {
  -- ====== Vimwiki（懒加载：命令触发）======
  {
    "vimwiki/vimwiki",
    cmd = { "VimwikiIndex", "VimwikiMakeDiaryNote", "VimwikiTabIndex" },
    init = function()
      vim.g.vimwiki_global_ext = 0
      vim.g.vimwiki_list = {
        { path = "~/Documents/vimwiki", syntax = "markdown", ext = ".md", auto_diary_index = 1 },
      }
    end,
    keys = {
      { "<leader>W", "<cmd>VimwikiIndex<cr>", desc = "Vimwiki index" },
    },
  },

  -- ====== R 语言（打开 R 文件前加载，保证 auto_start 正常触发）======
  {
    "R-nvim/R.nvim",
    event = { "BufReadPre", "BufNewFile" },
    pattern = { "*.R", "*.r", "*.Rmd", "*.rmd", "*.Rnw", "*.rnw", "*.qmd" },
    config = function()
      require("r").setup({
        R_args = { "--quiet", "--no-save" },
        auto_start = "always",
        min_editor_width = 72,
        rconsole_width = 78,
        hook = {
          on_filetype = function()
            vim.keymap.set("n", "<CR>", "<Plug>RDSendLine", { buffer = true })
            vim.keymap.set("v", "<CR>", "<Plug>RSendSelection", { buffer = true })
          end,
        },
        disable_cmds = {
          "RClearConsole",
          "RCustomStart",
          "RSPlot",
          "RSaveClose",
        },
      })
    end,
  },

  -- ====== Cargo 依赖管理（内置 LSP：blink 直接拿到版本补全/hover/code action）======
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    ft = { "rust", "toml" },
    config = function()
      require("crates").setup({
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
        },
      })
    end,
    keys = {
      {
        "<leader>Cp",
        function() require("crates").show_popup() end,
        ft = { "rust", "toml" },
        desc = "Crates popup (versions/features/deps)",
      },
    },
  },

  -- ====== Markdown 预览 ======
  {
    "OXY2DEV/markview.nvim",
    ft = "markdown",
    opts = {
      preview = {
        enable = true,
        filetypes = { "markdown" },
      },
    },
  },

  -- ====== AI 补全（minuet + DeepSeek ghost text，<M-m> 开关）======
  {
    "milanglacier/minuet-ai.nvim",
    event = "VeryLazy",
    config = function()
      -- 从 opencode auth.json 读取 DeepSeek Key
      local key = nil
      local f = io.open(vim.fn.expand("~/.local/share/opencode/auth.json"), "r")
      if f then
        local ok, data = pcall(vim.json.decode, f:read("*a"))
        f:close()
        if ok and data and data.deepseek and data.deepseek.key then
          key = data.deepseek.key
        end
      end
      if not key then
        vim.notify("minuet: DeepSeek key not found in auth.json", vim.log.levels.WARN)
        return
      end
      vim.env.DEEPSEEK_API_KEY = key
      require("minuet").setup({
        provider = "openai_fim_compatible",
        provider_options = {
          openai_fim_compatible = {
            api_key = "DEEPSEEK_API_KEY",
            name = "deepseek",
            optional = { max_tokens = 512, top_p = 0.9 },
          },
        },
        virtualtext = {
          auto_trigger_ft = {}, -- 默认关闭，<M-m> 手动开启
          keymap = {
            accept = "<A-A>",
            accept_line = "<A-a>",
            accept_n_lines = "<A-z>",
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<A-e>",
          },
        },
        add_single_line_entry = false,
        n_completions = 3,
        fetching_timeout = 2000,
      })
    end,
    keys = {
      { "<M-m>", "<cmd>Minuet virtualtext toggle<cr>", desc = "Minuet: toggle ghost text" },
    },
  },
}
