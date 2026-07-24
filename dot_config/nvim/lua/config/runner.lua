-- lua/config/runner.lua — 快速运行当前文件

local M = {}

local runners = {
  python = 'python3 "%s"',
  lua    = 'lua "%s"',
  sh     = 'bash "%s"',
  zsh    = 'zsh "%s"',
  rust   = 'cargo run --manifest-path "%s/Cargo.toml" 2>&1; read -n1 -p "Press any key..."',
  c      = function(f)
    local out = '/tmp/' .. vim.fn.fnamemodify(f, ':t:r')
    return string.format('gcc "%s" -o %s && %s; echo; read -n1 -p "Press any key..."', f, out, out)
  end,
  cpp    = function(f)
    local out = '/tmp/' .. vim.fn.fnamemodify(f, ':t:r')
    return string.format('g++ "%s" -o %s && %s; echo; read -n1 -p "Press any key..."', f, out, out)
  end,
  javascript = 'node "%s"',
  typescript = 'npx tsx "%s"',
  go     = 'go run "%s"',
  ruby   = 'ruby "%s"',
  zig    = 'zig run "%s"',
}

--- 运行当前文件
function M.run()
  local file = vim.fn.expand('%:p')
  if file == '' then
    vim.notify('No file to run', vim.log.levels.WARN)
    return
  end

  local ft = vim.bo.filetype
  local runner = runners[ft]
  if not runner then
    vim.notify('No runner for filetype: ' .. ft, vim.log.levels.WARN)
    return
  end

  local cmd
  if type(runner) == 'function' then
    cmd = runner(file)
  else
    cmd = string.format(runner, file)
  end

  require('snacks').terminal.toggle(cmd, { cwd = vim.fn.expand('%:p:h') })
end

return M
