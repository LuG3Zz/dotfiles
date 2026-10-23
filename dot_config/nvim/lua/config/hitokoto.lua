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

--- 一言还没拿到时 dashboard 上显示的占位文本
local PLACEHOLDER = '󰋞  …'

--- 异步获取一言：成功后写缓存，并把 dashboard 上的占位文本换成真格言。
--- 用 vim.system 异步执行 curl，主线程不再阻塞（旧版用 vim.fn.system
--- 同步 curl，网络慢时会卡住 dashboard 最长 5 秒）。
function M.fetch_async()
  pcall(vim.system, { 'curl', '-s', '--max-time', '5', 'https://v1.hitokoto.cn' }, { text = true }, function(result)
    if not result or not result.stdout or result.stdout == '' then
      return
    end
    local parsed, data = pcall(vim.json.decode, result.stdout)
    if not parsed or type(data) ~= 'table' or not data.hitokoto then
      return
    end
    local text = '󰋞  ' .. M.format(data)
    M.write_cache(text)
    M._refresh_dashboard(text)
  end)
end

--- 把 dashboard 中的占位文本替换为最新格言
---@param text string
function M._refresh_dashboard(text)
  vim.schedule(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if not vim.api.nvim_buf_is_loaded(buf) then goto continue end
      if vim.bo[buf].filetype ~= 'ministarter' then goto continue end
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      for i, line in ipairs(lines) do
        if line:find(PLACEHOLDER, 1, true) then
          local indent = line:match('^%s*') or ''
          vim.bo[buf].modifiable = true
          vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { indent .. text })
          vim.bo[buf].modifiable = false
        end
      end
      ::continue::
    end
  end)
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

  -- 缓存过期或不存在：异步获取，先返回占位文本，
  -- 拿到结果后由 M._refresh_dashboard 自动替换
  M.fetch_async()
  return PLACEHOLDER
end

--- Dashboard 显示
---@return string
function M.dashboard_text()
  return M.get_daily()
end

return M
