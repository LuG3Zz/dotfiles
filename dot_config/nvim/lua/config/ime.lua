-- lua/config/ime.lua — 异步输入法自动切换（替代 fcitx.nvim）
--
-- fcitx.nvim 在 InsertEnter/InsertLeave/Cmdline/Term/FocusGained 时用
-- vim.fn.system() 同步调用 fcitx5-remote，会阻塞 UI 线程：实测 10 轮
-- i/Esc 从 4.5ms 涨到 71.9ms（fcitx5 忙时更久）。这里用 vim.system
-- 异步执行，行为保持一致。
local M = {}

local cmd = nil
if vim.fn.executable("fcitx5-remote") == 1 then
  cmd = "fcitx5-remote"
elseif vim.fn.executable("fcitx-remote") == 1 then
  cmd = "fcitx-remote"
end
if not cmd then return M end
if os.getenv("SSH_TTY") ~= nil then return M end
if vim.uv.os_uname().sysname ~= "Linux" then return M end
if os.getenv("DISPLAY") == nil and os.getenv("WAYLAND_DISPLAY") == nil then return M end

---@param args string[]
---@param on_done? fun(res: table)
local function run(args, on_done)
  vim.system(vim.list_extend({ cmd }, args or {}), { text = true }, function(res)
    if on_done then vim.schedule(function() on_done(res) end) end
  end)
end

-- 离开输入态：若当前是非英文（fcitx 状态 2），切回英文并记住，
-- 下次进入输入态时恢复（与原插件语义一致）
local function to_en()
  local buf = vim.api.nvim_get_current_buf()
  run({}, function(res)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local status = tonumber((res.stdout or ""):match("%d+") or "")
    if status ~= 2 then return end
    -- 查询是异步的：若回包时用户已经又回到输入态（快速 Esc→i），
    -- 直接恢复中文，而不是先切英文再等下一次 -o。
    local mode = vim.api.nvim_get_mode().mode
    if mode:match("^[iR]") or vim.bo[buf].buftype == "terminal" then
      vim.b[buf].input_toggle_flag = false
      run({ "-o" })
      return
    end
    vim.b[buf].input_toggle_flag = true
    run({ "-c" })
  end)
end

local function to_nonlatin()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].input_toggle_flag == true then
    vim.b[buf].input_toggle_flag = false
    run({ "-o" })
  end
end

local group = vim.api.nvim_create_augroup("UserIME", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", { group = group, callback = to_nonlatin })
vim.api.nvim_create_autocmd("InsertLeave", { group = group, callback = to_en })
vim.api.nvim_create_autocmd("CmdlineEnter", { group = group, pattern = "[/?]", callback = to_nonlatin })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = group, pattern = "[/?]", callback = to_en })
vim.api.nvim_create_autocmd("TermEnter", { group = group, callback = to_nonlatin })
vim.api.nvim_create_autocmd("TermLeave", { group = group, callback = to_en })
vim.api.nvim_create_autocmd("FocusGained", {
  group = group,
  callback = function()
    local m = vim.fn.mode()
    if m == "n" or m:match("^[vV\22sS]") then
      to_en()
    end
  end,
})

return M
