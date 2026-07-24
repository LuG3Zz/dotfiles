-- lua/config/runner.lua — 浮动终端运行代码
-- 用 asyncrun.vim 获取命令，snacks.terminal 浮窗显示

local M = {}

local runners = {
  python     = 'python3 "%s"',
  lua        = 'lua "%s"',
  sh         = 'bash "%s"',
  zsh        = 'zsh "%s"',
  rust       = 'cargo run',
  c          = 'gcc "%s" -o /tmp/a.out && /tmp/a.out',
  cpp        = 'g++ "%s" -o /tmp/a.out && /tmp/a.out',
  javascript = 'node "%s"',
  typescript = 'npx tsx "%s"',
  go         = 'go run "%s"',
  ruby       = 'ruby "%s"',
  markdown   = 'glow "%s"',
}

function M.run()
  local file = vim.fn.expand('%:p')
  if file == '' then
    vim.notify('No file to run', vim.log.levels.WARN)
    return
  end

  local ft = vim.bo.filetype
  local runner = runners[ft]
  if not runner then
    vim.notify('No runner for: ' .. ft, vim.log.levels.WARN)
    return
  end

  local cmd = type(runner) == 'function' and runner(file) or string.format(runner, file)
  require('snacks').terminal.toggle(cmd, {
    cwd = vim.fn.expand('%:p:h'),
  })
end

return M
