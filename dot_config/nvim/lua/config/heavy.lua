-- lua/config/heavy.lua — 一键关掉"重"的 UI 组件，用来二分定位卡顿
--
--   :HeavyOff            关掉全部（见下）
--   :HeavyOff ts smear   只关指定项
--   :HeavyOn             恢复全部
--   :HeavyOn ts          只恢复指定项
--
-- 可选项：
--   smear   smear-cursor 光标拖影动画
--   indent  snacks 缩进线
--   words   snacks 光标词高亮
--   scope   snacks 当前作用域高亮
--   ts      treesitter 高亮
--   hints   LSP inlay hints
--   fold    折叠（改成 manual）
--   status  状态行（lualine）
--   winbar  winbar / dropbar 面包屑（删除自动命令，需重启才能完全恢复）
local M = {}

local saved = {}

local function try(fn)
  pcall(fn)
end

local items = {
  smear = {
    off = function()
      saved.smear = require("smear_cursor").enabled
      require("smear_cursor").enabled = false
    end,
    on = function()
      require("smear_cursor").enabled = saved.smear ~= false
    end,
  },
  indent = {
    off = function()
      require("snacks").indent.disable()
    end,
    on = function()
      require("snacks").indent.enable()
    end,
  },
  words = {
    off = function()
      require("snacks").words.disable()
    end,
    on = function()
      require("snacks").words.enable()
    end,
  },
  scope = {
    off = function()
      require("snacks").scope.disable()
    end,
    on = function()
      require("snacks").scope.enable()
    end,
  },
  ts = {
    off = function()
      vim.treesitter.stop(0)
    end,
    on = function()
      vim.treesitter.start(0)
    end,
  },
  hints = {
    off = function()
      vim.lsp.inlay_hint.enable(false, { bufnr = 0 })
    end,
    on = function()
      vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
    end,
  },
  fold = {
    off = function()
      saved.foldmethod = vim.wo.foldmethod
      vim.wo.foldmethod = "manual"
    end,
    on = function()
      vim.wo.foldmethod = saved.foldmethod or "expr"
    end,
  },
  status = {
    off = function()
      saved.laststatus = vim.o.laststatus
      vim.o.laststatus = 0
    end,
    on = function()
      vim.o.laststatus = saved.laststatus or 3
    end,
  },
  winbar = {
    off = function()
      saved.winbar = vim.wo.winbar
      vim.wo.winbar = ""
      for _, name in ipairs({ "dropbar", "dropbar.sources", "dropbar.sources.lsp", "dropbar.sources.path", "dropbar.sources.treesitter" }) do
        pcall(vim.api.nvim_del_augroup_by_name, name)
      end
    end,
    on = function()
      vim.wo.winbar = saved.winbar or ""
    end,
  },
}

local function run(arg, which)
  local names = {}
  if arg and arg ~= "" then
    names = vim.split(arg, "%s+", { trimempty = true })
  else
    names = vim.tbl_keys(items)
    table.sort(names)
  end
  local done = {}
  for _, name in ipairs(names) do
    local it = items[name]
    if it then
      try(it[which])
      done[#done + 1] = name
    end
  end
  vim.notify(("%s: %s"):format(which == "off" and "已关闭" or "已恢复", table.concat(done, " ")))
end

function M.off(arg)
  run(arg, "off")
end

function M.on(arg)
  run(arg, "on")
end

vim.api.nvim_create_user_command("HeavyOff", function(o)
  M.off(o.args)
end, { nargs = "*", desc = "关闭重 UI 组件（排查卡顿）" })

vim.api.nvim_create_user_command("HeavyOn", function(o)
  M.on(o.args)
end, { nargs = "*", desc = "恢复 UI 组件" })

return M
