-- lua/config/translate.lua — kd 终端词典翻译

local M = {}

--- 在浮动窗口中显示翻译结果
---@param text string 要翻译的文本
local function show_result(text, result)
  -- 创建新 buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, '\n', { plain = true }))
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'markdown'

  -- 计算窗口尺寸
  local lines = vim.api.nvim_buf_line_count(buf)
  local width = 60
  local height = math.min(lines, 20)
  local ui = vim.api.nvim_list_uis()[1]
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  -- 浮动窗口
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' kd: ' .. text .. ' ',
    title_pos = 'center',
  })
  vim.wo[win].cursorline = true

  -- 按 q 关闭
  vim.keymap.set('n', 'q', function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end, { buffer = buf })
end

--- 翻译光标下的单词或选中文本
function M.translate()
  -- 获取单词：优先 visual 选择，其次光标下单词
  local _, ls, cs = unpack(vim.fn.getpos("'<"))
  local _, le, ce = unpack(vim.fn.getpos("'>"))
  local text
  if vim.fn.mode():find('^[vV]') then
    text = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.mode() })
    text = table.concat(text or {}, ' ')
    vim.cmd('normal! <Esc>')
  else
    text = vim.fn.expand('<cword>')
  end

  if not text or text == '' then
    vim.notify('No word to translate', vim.log.levels.WARN)
    return
  end

  -- 调用 kd 查词
  local ok, result = pcall(vim.fn.system, { 'kd', text })
  if not ok or result == nil or result == '' then
    vim.notify('Translation failed', vim.log.levels.ERROR)
    return
  end

  show_result(text, result)
end

return M
