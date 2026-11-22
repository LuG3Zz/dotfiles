-- lua/config/perf.lua — 卡顿探针（默认关闭）
--
-- 用法：
--   NVIM_PERF_WATCH=1 nvim 你的文件
--   正常用，直到感觉到卡顿；然后 :PerfSummary
--   结果同时写到 /tmp/nvim-perf.log
--
-- 它能回答两个问题：
--   1. 哪条 autocmd 回调最慢（按 group / 事件 / desc 排序）
--   2. 主循环有没有被卡住（>20ms 的停顿），以及当时在哪个模式/哪一行
--
-- 注意：它在 nvim_create_autocmd 上包了一层计时，只在设置环境变量时启用。
local M = {}

if vim.env.NVIM_PERF_WATCH ~= "1" then
  return M
end

local uv = vim.uv
local LOG = "/tmp/nvim-perf.log"

local stats = {} -- id -> { n, total, max }
local slow = {} -- 最慢的若干次回调 { dt, label, mode }
local gaps = {} -- 主循环停顿 { dt, mode, line, bufnr }

local function now()
  return uv.hrtime()
end

-- ====== 1. 统计每条 autocmd 回调的耗时 ======
local orig_create = vim.api.nvim_create_autocmd
vim.api.nvim_create_autocmd = function(event, opts)
  if type(opts) ~= "table" or type(opts.callback) ~= "function" then
    return orig_create(event, opts)
  end
  local callback = opts.callback
  local id
  local wrapped = vim.tbl_extend("force", {}, opts)
  wrapped.callback = function(ev)
    local t0 = now()
    local ok, err = pcall(callback, ev)
    local dt = (now() - t0) / 1e6
    local s = stats[id]
    if not s then
      s = { n = 0, total = 0, max = 0 }
      stats[id] = s
    end
    s.n = s.n + 1
    s.total = s.total + dt
    if dt > s.max then
      s.max = dt
    end
    if dt > 8 then
      slow[#slow + 1] = { dt = dt, id = id, mode = vim.api.nvim_get_mode().mode }
      table.sort(slow, function(a, b)
        return a.dt > b.dt
      end)
      for i = #slow, 11, -1 do
        slow[i] = nil
      end
    end
    if not ok then
      error(err)
    end
  end
  id = orig_create(event, wrapped)
  return id
end

-- ====== 2. 主循环停顿检测 ======
local timer = uv.new_timer()
local last = now()
timer:start(2, 2, function()
  local t = now()
  local dt = (t - last) / 1e6
  last = t
  if dt > 20 then
    -- uv 回调是 fast event context，取 buffer/mode 要回主循环
    vim.schedule(function()
      local ok, line = pcall(function()
        return vim.api.nvim_win_get_cursor(0)[1]
      end)
      gaps[#gaps + 1] = {
        dt = dt,
        mode = vim.api.nvim_get_mode().mode,
        line = ok and line or -1,
        file = vim.api.nvim_buf_get_name(0),
      }
    end)
  end
end)

-- ====== 3. 汇总 ======
local function label_of(id)
  local ok, aus = pcall(vim.api.nvim_get_autocmds, {})
  if not ok then
    return "id=" .. tostring(id)
  end
  for _, a in ipairs(aus) do
    if a.id == id then
      local ev = type(a.event) == "table" and table.concat(a.event, ",") or tostring(a.event)
      local parts = { ev }
      if a.group_name and a.group_name ~= "" then
        parts[#parts + 1] = a.group_name
      end
      if a.desc and a.desc ~= "" then
        parts[#parts + 1] = a.desc
      end
      return table.concat(parts, " / ")
    end
  end
  return "id=" .. tostring(id)
end

function M.summary()
  local rows = {}
  for id, s in pairs(stats) do
    rows[#rows + 1] = {
      label = label_of(id),
      n = s.n,
      avg = s.total / s.n,
      max = s.max,
    }
  end
  table.sort(rows, function(a, b)
    return a.max > b.max
  end)

  local out = { "=== 最慢的 autocmd 回调 ===" }
  for i = 1, math.min(#rows, 20) do
    local r = rows[i]
    out[#out + 1] = string.format("%8.1fms 最大  %7.1fms 平均  x%-5d %s", r.max, r.avg, r.n, r.label)
  end

  out[#out + 1] = ""
  out[#out + 1] = "=== 单次最慢的回调 ==="
  for i = 1, math.min(#slow, 10) do
    local s = slow[i]
    out[#out + 1] = string.format("%8.1fms  mode=%s  %s", s.dt, s.mode, label_of(s.id))
  end

  out[#out + 1] = ""
  out[#out + 1] = string.format("=== 主循环停顿 >20ms：%d 次 ===", #gaps)
  for i = math.max(1, #gaps - 14), #gaps do
    local g = gaps[i]
    if g then
      out[#out + 1] = string.format(
        "%8.1fms  mode=%s  line=%d  %s",
        g.dt,
        g.mode,
        g.line,
        vim.fn.fnamemodify(g.file, ":t")
      )
    end
  end

  local text = table.concat(out, "\n")
  local f = io.open(LOG, "w")
  if f then
    f:write(text .. "\n")
    f:close()
  end
  print(text)
  return text
end

function M.reset()
  stats, slow, gaps = {}, {}, {}
  print("perf: 统计已清空")
end

vim.api.nvim_create_user_command("PerfSummary", function()
  M.summary()
end, { desc = "显示卡顿探针统计" })

vim.api.nvim_create_user_command("PerfReset", function()
  M.reset()
end, { desc = "清空卡顿探针统计" })

return M
