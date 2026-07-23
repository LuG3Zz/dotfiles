-- lua/config/completion.lua — blink.cmp 补全配置

-- V2 原生库编译：检测 .so 不存在时自动编译
local lib_dir = vim.fn.stdpath('data') .. '/site/pack/core/opt/blink.cmp/lib'
local has_lib = vim.fn.glob(lib_dir .. '/*.so*') ~= ''
if not has_lib then
  vim.notify('blink.cmp: building native library...', vim.log.levels.INFO)
  vim.cmd('lua require("blink.cmp").build():pwait()')
  vim.notify('blink.cmp: build complete', vim.log.levels.INFO)
end

local blink_ok, blink = pcall(require, 'blink.cmp')
if not blink_ok then
  return
end

blink.setup({
  keymap = {
    preset = 'default',
    ['<C-space>'] = { 'show', 'hide' },
    ['<C-n>'] = { 'select_next', 'snippet_forward' },
    ['<C-p>'] = { 'select_prev', 'snippet_backward' },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono',
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 300,
    },
    ghost_text = { enabled = false },
  },

  signature = {
    enabled = true,
    window = { border = 'rounded' },
  },
})
