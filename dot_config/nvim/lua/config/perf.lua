-- lua/config/perf.lua — 卡顿探针（默认关闭）
--
-- 用法：
--   NVIM_PERF_WATCH=1 nvim 你的文件
--   正常用，直到感觉到卡顿；然后 :PerfSummary
--   结果同时写到 /tmp/nvim-perf.log
--
-- 三个口径：
--   1. 按键处理耗时：从按键进入 nvim 到主循环重新空闲（含 autocmd + 重绘
--      准备）。这个最能区分"nvim 慢"还是"nvim 外面慢"。
--   2. 每条 autocmd 回调的耗时（按 group / 事件 / desc 排序）。
--   3. 主循环停顿（定时器间隔），记录当时的模式/行号/文件。
--
-- 阈值可用 NVIM_PERF_THRESHOLD 调整（默认 10ms）。
local M = {}

if vim.env.NVIM_PERF_WATCH ~= "1" then
  return M
end

local uv = vim.uv
local LOG = "/tmp/nvim-perf.log"
local THRESH = tonumber(vim.env.NVIM_PERF_THRESHOLD) or 10

local stats = {} -- autocmd id -> { n, total, max }
local slow = {} -- 最慢的若干次 autocmd 回调
local gaps = {} -- 主循环停顿
local keys = {} -- 每次按键的耗时（毫秒）
local slowkeys = {} -- 超过阈值的按键

local function now()
  return uv.hrtime()
end

-- ====== 1. 按键处理耗时：按键 → 主循环空闲 ======
vim.on_key(function(c)
  local t0 = now()
  vim.schedule(function()
    local dt = (now() - t0) / 1e6
    keys[#keys + 1] = dt
    if #keys > 5000 then
      table.remove(keys, 1)
    end
    if dt > THRESH then
      local ok, txt = pcall(vim.fn.keytrans, c)
      slowkeys[#slowkeys + 1] = {
        dt = dt,
        key = ok and txt or "?",
        mode = vim.api.nvim_get_mode().mode,
      }
      if #slowkeys > 60 then
        table.remove(slowkeys, 1)
      end
    end
  end)
end)

-- ====== 2. 统计每条 autocmd 回调的耗时 ======
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
    if dt > 3 then
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

-- ====== 3. 主循环停顿 ======
local timer = uv.new_timer()
local last = now()
timer:start(2, 2, function()
  local t = now()
  local dt = (t - last) / 1e6
  last = t
  if dt > THRESH then
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

-- ====== 4. 汇总 ======
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

local function pct(sorted, q)
  if #sorted == 0 then
    return 0
  end
  local i = math.max(1, math.min(#sorted, math.floor(#sorted * q)))
  return sorted[i]
end

function M.summary()
  local out = {}

  -- 按键
  local sorted_keys = vim.deepcopy(keys)
  table.sort(sorted_keys)
  local total = 0
  for _, v in ipairs(keys) do
    total = total + v
  end
  out[#out + 1] = string.format(
    "=== 按键处理耗时（按键 → nvim 空闲，共 %d 次）p50=%.1fms p95=%.1fms p99=%.1fms max=%.1fms 平均=%.1fms ===",
    #keys,
    pct(sorted_keys, 0.5),
    pct(sorted_keys, 0.95),
    pct(sorted_keys, 0.99),
    #sorted_keys > 0 and sorted_keys[#sorted_keys] or 0,
    #keys > 0 and total / #keys or 0
  )
  out[#out + 1] = string.format("超过 %dms 的按键：%d 次", THRESH, #slowkeys)
  for i = 1, math.min(#slowkeys, 20) do
    local s = slowkeys[i]
    out[#out + 1] = string.format("  %7.1fms  key=%-6s mode=%s", s.dt, s.key, s.mode)
  end

  -- autocmd
  local rows = {}
  for id, s in pairs(stats) do
    rows[#rows + 1] = { label = label_of(id), n = s.n, avg = s.total / s.n, max = s.max }
  end
  table.sort(rows, function(a, b)
    return a.max > b.max
  end)
  out[#out + 1] = ""
  out[#out + 1] = "=== 最慢的 autocmd 回调 ==="
  for i = 1, math.min(#rows, 15) do
    local r = rows[i]
    out[#out + 1] = string.format("%8.1fms 最大  %7.2fms 平均  x%-5d %s", r.max, r.avg, r.n, r.label)
  end

  out[#out + 1] = ""
  out[#out + 1] = "=== 单次最慢的回调 ==="
  for i = 1, math.min(#slow, 8) do
    local s = slow[i]
    out[#out + 1] = string.format("%8.1fms  mode=%s  %s", s.dt, s.mode, label_of(s.id))
  end

  -- 停顿
  out[#out + 1] = ""
  out[#out + 1] = string.format("=== 主循环停顿 >%dms：%d 次 ===", THRESH, #gaps)
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
  stats, slow, gaps, keys, slowkeys = {}, {}, {}, {}, {}
  print("perf: 统计已清空")
end

vim.api.nvim_create_user_command("PerfSummary", function()
  M.summary()
end, { desc = "显示卡顿探针统计" })

vim.api.nvim_create_user_command("PerfReset", function()
  M.reset()
end, { desc = "清空卡顿探针统计" })

return M
