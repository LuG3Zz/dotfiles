-- norg 文件缓冲区设置

pcall(vim.keymap.del, 'n', '<C-Space>', { buffer = true })
pcall(vim.keymap.del, 'i', '<C-Space>', { buffer = true })

vim.keymap.set('n', '<leader>tx', '<Plug>(neorg.qol.todo-items.todo.task-cycle)', { buffer = true, desc = '[neorg] Cycle Task' })
vim.keymap.set('n', '<CR>', function()
  local hop = require('neorg.core').modules.get_module('core.esupports.hop')
  if hop then hop.hop_link() end
end, { buffer = true, desc = '[neorg] Jump to Link' })
