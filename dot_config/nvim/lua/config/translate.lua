-- lua/config/translate.lua — kd 终端词典翻译
--   <leader>kd   查看翻译（浮动窗口）
--   <leader>kD   替换为中文释义

local M = {}

--- 获取要翻译的文本
---@return string|nil text
local function get_text()
  if vim.fn.mode():find('^[vV]') then
    local text = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.mode() })
    return table.concat(text or {}, ' ')
  end
  return vim.fn.expand('<cword>')
end

--- 用翻译替换选区
---@param text string 原文本
local function replace_selection(text)
  local result = vim.fn.system({ 'kd', text })
  if result == nil or result == '' then
    vim.notify('Translation failed', vim.log.levels.ERROR)
    return
  end
  -- 提取首条中文释义
  local def
  for line in result:gmatch('[^\n]+') do
    local d = line:match('^%w+%.%s*(.*)')
    if d and d:match('[\x{4e00}-\x{9fff}]') then def = d; break end
  end
  if not def then
    vim.notify('No Chinese definition found', vim.log.levels.WARN)
    return
  end

  -- 替换当前光标下的单词或选区
  vim.cmd('normal! ciw' .. def)
end

--- 查词（浮动窗口展示）
function M.show()
  local text = get_text()
  if not text or text == '' then vim.notify('No word', vim.log.levels.WARN) return end

  local ok, result = pcall(vim.fn.system, { 'kd', text })
  if not ok or result == nil or result == '' then
    vim.notify('Translation failed', vim.log.levels.ERROR)
    return
  end

  -- 浮动窗口展示结果
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, '\n', { plain = true }))
  vim.bo[buf].modifiable, vim.bo[buf].filetype = false, 'markdown'

  local lines = vim.api.nvim_buf_line_count(buf)
  local width, height = 60, math.min(lines, 20)
  local ui = vim.api.nvim_list_uis()[1]
  local row = ui and math.floor((ui.height - height) / 2) or 2
  local col = ui and math.floor((ui.width - width) / 2) or 10

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor', width = width, height = height,
    row = row, col = col, style = 'minimal',
    border = 'rounded', title = ' kd: ' .. text .. ' ', title_pos = 'center',
  })
  vim.keymap.set('n', 'q', function()
    pcall(vim.api.nvim_win_close, win, true)
  end, { buffer = buf })

  -- 点击翻译内容时自动替换光标下单词
  vim.keymap.set('n', '<CR>', function()
    pcall(vim.api.nvim_win_close, win, true)
    replace_selection(text)
  end, { buffer = buf, desc = 'Replace word with translation' })
end

--- 直接替换为中文释义（不展示浮动窗口）
function M.replace()
  local text = get_text()
  if not text or text == '' then vim.notify('No word', vim.log.levels.WARN) return end
  replace_selection(text)
end

return M
