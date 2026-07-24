-- asyncrun snacks.terminal runner
local M = {}

function M.run(opts)
  local cmd = opts.cmd or ''
  local cwd = (opts.cwd or '') ~= '' and opts.cwd or vim.fn.getcwd()
  require('snacks').terminal.toggle(cmd, {
    cwd = cwd,
    interactive = false,
    auto_close = false,
  })
end

return M
