-- lua/config/runner.lua — 快速运行代码（asyncrun.vim）

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
  vim.cmd('AsyncRun ' .. cmd)
end

return M
