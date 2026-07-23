-- lua/config/completion.lua — blink.cmp 补全配置

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
