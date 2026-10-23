-- lua/config/completion.lua — blink.cmp 补全配置

-- V2 原生库编译
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
    ['<C-f>'] = { 'show', 'hide' },
    ['<C-n>'] = { 'select_next', 'snippet_forward' },
    ['<C-p>'] = { 'select_prev', 'snippet_backward' },
    ['<CR>'] = { 'accept', 'fallback' },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono',
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    min_keyword_length = 2,   -- 输入 2 字符才触发，避免打字就弹
    providers = {
      buffer = { max_items = 5 },
    },
  },

  snippets = { preset = 'default' },    -- 使用 Neovim 原生 vim.snippet

  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
    ghost_text = { enabled = true },
    list = { max_items = 15 },
    menu = {
      -- 自动弹出补全菜单。
      -- 原来这里有个 `auto_show = function(ctx) return ctx.mode ~= "default" end`，
      -- 是为旧的 neocodeium 集成留的绕过配置（避免和 AI ghost text 抢位置）。
      -- neocodeium 已废弃，AI 补全改用 minuet-ai（独立 virtualtext，<A-m> 开关），
      -- 留着它会导致 default 模式下打字永远不弹菜单。
      auto_show = true,
    },
  },

  signature = {
    enabled = true,
    window = { border = 'rounded' },
  },
})
