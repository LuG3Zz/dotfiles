-- lua/config/translate.lua — kd 终端词典翻译
--   <leader>kd   键盘下单词或选中文本

local M = {}

--- 翻译光标下的单词或选中文本
function M.show()
  -- 获取单词
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

  -- 调用 kd
  local ok, result = pcall(vim.fn.system, { 'kd', text })
  if not ok or result == nil or result == '' then
    vim.notify('Translation failed', vim.log.levels.ERROR)
    return
  end

  -- 浮动窗口展示结果
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, '\n', { plain = true }))
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'markdown'

  local lines = vim.api.nvim_buf_line_count(buf)
  local width = 60
  local height = math.min(lines, 20)
  local ui = vim.api.nvim_list_uis()[1]
  local row = ui and math.floor((ui.height - height) / 2) or 2
  local col = ui and math.floor((ui.width - width) / 2) or 10

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

  vim.keymap.set('n', 'q', function()
    pcall(vim.api.nvim_win_close, win, true)
  end, { buffer = buf })
end

return M
