-- dial.nvim 懒加载封装
-- 启动时不再 packadd：plugin/dial.lua + dial.map/command/config/augend
-- 合计约 100ms，属于纯启动浪费。首次按 <C-a>/<C-x> 时才加载并配置 augends。
local M = {}

local ready = false

--- 首次调用时加载 dial.nvim 并注册自定义 augends（幂等）
function M.ensure()
  if ready then return end
  ready = true

  vim.cmd.packadd('dial.nvim')

  -- 在默认 augends 基础上增加 boolean、字母、英式星期等
  local dial_config = require('dial.config')
  local constant = require('dial.augend.constant')
  local default_augends = dial_config.augends:get('default')
  vim.list_extend(default_augends, {
    constant.alias.bool,
    constant.alias.Bool,
    constant.alias.alpha,
    constant.alias.Alpha,
    constant.alias.en_weekday,
  })
end

--- 模拟按下 dial 的 <Plug> 映射（保留 visual 模式下的 gv 重选行为）
---@param action "increment"|"decrement"
function M.press(action)
  M.ensure()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<Plug>(dial-' .. action .. ')', true, false, true),
    'm',
    false
  )
end

return M
