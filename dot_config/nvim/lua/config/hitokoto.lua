-- lua/config/hitokoto.lua — 一言 API 随机格言
-- 使用 Neovim 0.12 内置 vim.json.decode 解析 JSON
-- API: https://v1.hitokoto.cn

local M = {}

--- 从一言 API 获取随机句子
---@return table|nil data { hitokoto, from, from_who, ... }
---@return string|nil err
function M.fetch()
  -- 使用 curl 获取 JSON（同步，适合 Dashboard 启动时加载）
  local ok, result = pcall(vim.fn.system, { 'curl', '-s', '--max-time', '5', 'https://v1.hitokoto.cn' })
  if not ok or result == nil or result == '' then
    return nil, 'Network error'
  end

  -- Neovim 0.12 内置 JSON 解析
  local parsed, data = pcall(vim.json.decode, result)
  if not parsed or not data.hitokoto then
    return nil, 'Parse error'
  end

  return data, nil
end

--- 格式化为可读字符串
---@return string
function M.format()
  local data, err = M.fetch()
  if not data then
    return '⚡  ' .. (err or 'unknown error')
  end

  local quote = data.hitokoto
  -- 优先显示作者(from_who)，其次出处(from)，都没有就只显示句子
  -- 处理 vim.NIL（JSON null）的情况
  local source
  if data.from_who ~= vim.NIL and data.from_who ~= nil and data.from_who ~= '' then
    source = data.from_who
  elseif data.from ~= vim.NIL and data.from ~= nil and data.from ~= '' then
    source = data.from
  end
  if source then
    return '「' .. quote .. '」 —— ' .. source
  end
  return '「' .. quote .. '」'
end

--- 在 Dashboard 中显示的格式（带前缀图标）
---@return string
function M.dashboard_text()
  return '󰋞  ' .. M.format()
end

return M
