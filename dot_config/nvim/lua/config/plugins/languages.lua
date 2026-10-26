-- lua/config/plugins/languages.lua — 语言与文档
-- vimwiki（懒加载）/ markview（Markdown 预览）/ R.nvim（按文件类型懒加载）

-- vimwiki：g: 变量必须在大加载前设置，插件本体延后到 VimEnter 之后再
-- packadd（省约 30ms 启动）。交互使用时一定已经加载完成；
-- 若启动参数直接带 :Vimwiki* 命令，则用 CmdUndefined 兜底加载。
vim.g.vimwiki_global_ext = 0
vim.g.vimwiki_list =
  { { path = "~/Documents/vimwiki", syntax = "markdown", ext = ".md", auto_diary_index = 1 } }

local vimwiki_loaded = false
local function load_vimwiki()
  if vimwiki_loaded then return end
  vimwiki_loaded = true
  vim.cmd.packadd("vimwiki")
  vim.cmd([[let g:vimwiki_global_vars.key_mappings.lists_return = 0]])
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function() vim.schedule(load_vimwiki) end,
})
vim.api.nvim_create_autocmd("CmdUndefined", {
  pattern = "Vimwiki*",
  callback = load_vimwiki,
})

-- ====== Markdown 预览 (markview.nvim) ======
local mv_ok, mv = pcall(require, "markview")
if mv_ok then
  mv.setup({
    preview = {
      enable = true,
      filetypes = { "markdown", "md" },
    },
  })
end

-- ====== R 语言开发 (R.nvim)：按文件类型懒加载 ======
-- 启动时不 packadd（省插件文件 + r 模块链约 15ms），
-- 打开 .R/.Rmd/.Rnw/.qmd 时再加载；用 BufReadPre 保证早于 FileType，
-- 这样 R.nvim 自己的 FileType autocmd（auto_start）也能正常触发。
local r_setup_done = false
local function setup_r()
  if r_setup_done then return end
  r_setup_done = true
  vim.cmd.packadd("R.nvim")
  local r_ok, rlg = pcall(require, "r")
  if not r_ok then return end
  rlg.setup({
    R_args = { "--quiet", "--no-save" },
    -- 编辑 R 文件时自动启动 R 会话（否则按 Enter 会提示 "Did you start R?"）
    auto_start = "always",
    min_editor_width = 72,
    rconsole_width = 78,
    hook = {
      on_filetype = function()
        -- 发送当前行 / 选中代码到 R 终端
        vim.keymap.set("n", "<CR>", "<Plug>RDSendLine", { buffer = true })
        vim.keymap.set("v", "<CR>", "<Plug>RSendSelection", { buffer = true })
      end,
    },
    -- 禁止自动打开窗口
    disable_cmds = {
      "RClearConsole",
      "RCustomStart",
      "RSPlot",
      "RSaveClose",
    },
  })
end
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  pattern = { "*.R", "*.r", "*.Rmd", "*.rmd", "*.Rnw", "*.rnw", "*.qmd" },
  callback = setup_r,
})
-- 兜底：手动 :set ft=r 的情况（此时 auto_start 不会对当前 buffer 生效）
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "r", "rmd", "quarto", "rnoweb" },
  callback = setup_r,
})
