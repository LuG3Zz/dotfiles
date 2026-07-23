-- lua/config/hitokoto.lua — 一言 API 随机格言
-- 使用 Neovim 0.12 内置 vim.json.decode/encode
-- 每日第一次打开 Dashboard 时刷新，之后使用缓存
-- API: https://v1.hitokoto.cn

local M = {}

local cache_file = vim.fn.stdpath('state') .. '/hitokoto.json'

--- 获取今天的日期字符串 YYYY-MM-DD
---@return string
local function today()
  return os.date('%Y-%m-%d')
end

--- 从缓存文件读取今日格言
---@return string|nil
function M.read_cache()
  local ok, content = pcall(vim.fn.readfile, cache_file)
  if not ok or not content or #content == 0 then
    return nil
  end
  local parsed, data = pcall(vim.json.decode, table.concat(content, ''))
  if not parsed or data.date ~= today() then
    return nil
  end
  return data.text
end

--- 写入今日格言到缓存
---@param text string
function M.write_cache(text)
  local ok, dir = pcall(vim.fn.mkdir, vim.fn.fnamemodify(cache_file, ':h'), 'p')
  if not ok then
    return
  end
  local data = vim.json.encode({ date = today(), text = text })
  pcall(vim.fn.writefile, { data }, cache_file)
end

--- 从一言 API 获取随机句子
---@return table|nil data { hitokoto, from, from_who, ... }
---@return string|nil err
function M.fetch()
  local ok, result = pcall(vim.fn.system, { 'curl', '-s', '--max-time', '5', 'https://v1.hitokoto.cn' })
  if not ok or result == nil or result == '' then
    return nil, 'Network error'
  end
  local parsed, data = pcall(vim.json.decode, result)
  if not parsed or not data.hitokoto then
    return nil, 'Parse error'
  end
  return data, nil
end

--- 格式化为可读字符串
---@param data table
---@return string
function M.format(data)
  local quote = data.hitokoto
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

--- 获取每日格言（优先读缓存，缓存过期或不存在才调 API）
---@return string
function M.get_daily()
  -- 先尝试读缓存
  local cached = M.read_cache()
  if cached then
    return cached
  end

  -- 缓存过期或不存在，调 API 获取
  local data, err = M.fetch()
  if not data then
    return '󰋞  ⚡ ' .. (err or 'unknown error')
  end

  local text = '󰋞  ' .. M.format(data)
  M.write_cache(text)
  return text
end

--- Dashboard 显示
---@return string
function M.dashboard_text()
  return M.get_daily()
end

return M
