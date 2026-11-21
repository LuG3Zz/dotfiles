-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- 这里只放个人自动命令（LazyVim 已内置：yank 高亮、markdown wrap+spell、q 关闭列表等）。

local group = vim.api.nvim_create_augroup("UserAutocmds", { clear = true })

-- 保存时自动创建缺失的中间目录
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  callback = function(ev)
    if ev.match:match("^%w%w+:[/\\][/\\]") then
      return
    end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- .env 文件按 sh 语法
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = group,
  pattern = { "*.env", ".env.*" },
  callback = function()
    vim.opt_local.filetype = "sh"
  end,
})

-- 窗口尺寸变化时均衡分屏
vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  callback = function()
    local cur = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. cur)
  end,
})

-- Insert 模式下关闭相对行号
vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  callback = function()
    vim.opt.relativenumber = false
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = group,
  callback = function()
    vim.opt.relativenumber = true
  end,
})
