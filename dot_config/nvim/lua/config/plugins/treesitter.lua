-- lua/config/plugins/treesitter.lua — 语法高亮
-- nvim-treesitter（main 分支 API）+ 彩虹括号

-- ====== Treesitter ======
-- 注意：nvim-treesitter 使用的是 main 分支（重写版）。
-- 旧 API `nvim-treesitter.configs` 已被移除，ensure_installed/highlight/
-- indent 等配置项全部失效（pcall 吞错导致无声失败），必须改用新写法：
--   1. require("nvim-treesitter").install(...)  安装 parser（异步，已装的为 no-op）
--   2. 自己用 FileType autocmd 调 vim.treesitter.start() 开启高亮
--   3. indent 用 indentexpr 开启
local ts_ok, tsmod = pcall(require, "nvim-treesitter")
if ts_ok then
  tsmod.setup({}) -- install_dir 默认 stdpath("data")/site（已在 rtp 上）

  -- 延后到启动完成后：install 会连锁加载 nvim-treesitter.install（~8ms），
  -- 且 parser 已齐全时它只是空检查，不该占用启动时间
  vim.schedule(function()
    tsmod.install({
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "rust",
      "c",
      "cpp",
      "bash",
      "r",
      "rnoweb",
      "csv",
    }) -- 异步安装，缺的会补，已有的跳过
  end)

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
    callback = function(args)
      local buf = args.buf
      local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
      -- 没有对应 parser 的文件类型不动
      -- （get_parser 太宽松，无 parser 时也可能返回 true，用 add 严格判断）
      if not lang or not pcall(vim.treesitter.language.add, lang) then
        return
      end
      pcall(vim.treesitter.start, buf)
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

-- ====== 彩虹括号 ======
-- rainbow-delimiters.nvim: 使用 Treesitter 高亮括号层级
-- 默认配置即可工作，无需额外 setup
