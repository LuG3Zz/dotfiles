-- lua/config/theme.lua — 主题按需加载
-- 启动时只 setup 当前主题（gruvbox 或 catppuccin），切换时再加载另一个，
-- 避免两套主题都 require（约 12-22ms 启动开销）。
local M = {}

local done = {}

local function setup_gruvbox()
  if done.gruvbox then return end
  local ok, gruvbox = pcall(require, "gruvbox")
  if not ok then return end
  gruvbox.setup({
    transparent_mode = true,
    contrast = "soft",
    italic = { strings = false, comments = false },
    overrides = {},
  })
  done.gruvbox = true
end

local function setup_catppuccin()
  if done.catppuccin then return end
  local ok, cp = pcall(require, "catppuccin")
  if not ok then return end
  cp.setup({
    flavour = "mocha",
    transparent_background = true,
    no_italic = true,
    integrations = {
      treesitter = true,
      cmp = true,
      snacks = true,
      mini = true,
    },
  })
  done.catppuccin = true
end

--- 应用主题（首次调用时完成对应 setup）
---@param name "gruvbox"|"catppuccin"
function M.apply(name)
  if name == "catppuccin" then
    setup_catppuccin()
  else
    setup_gruvbox()
  end
  pcall(vim.cmd.colorscheme, name)
end

--- 读取持久化的主题名（默认 gruvbox）
---@return "gruvbox"|"catppuccin"
function M.saved()
  local ok, lines = pcall(vim.fn.readfile, vim.fn.stdpath("state") .. "/theme")
  if ok and lines and lines[1] and lines[1] ~= "" then
    return lines[1]
  end
  return "gruvbox"
end

--- 持久化主题名
---@param name string
function M.save(name)
  vim.fn.writefile({ name }, vim.fn.stdpath("state") .. "/theme")
end

--- 在 gruvbox / catppuccin 之间切换并持久化
function M.toggle()
  local themes = { "gruvbox", "catppuccin" }
  local current = vim.g.colors_name or "gruvbox"
  local next_name = (themes[1] == current and themes[2])
    or (themes[2] == current and themes[1])
    or themes[1]
  M.apply(next_name)
  M.save(next_name)
  vim.notify("Theme: " .. next_name, vim.log.levels.INFO)
end

return M
