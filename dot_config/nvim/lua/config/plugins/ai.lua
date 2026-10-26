-- lua/config/plugins/ai.lua — AI 补全
-- minuet-ai.nvim（DeepSeek，ghost text 模式；<A-m> 开关）

-- ====== AI 补全 (minuet-ai.nvim + DeepSeek) ======
-- 从 opencode auth.json 读取 DeepSeek Key，写入临时环境变量供 minuet 使用
local function get_deepseek_key()
  local auth_path = vim.fn.expand("~/.local/share/opencode/auth.json")
  local f = io.open(auth_path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  if ok and data and data.deepseek and data.deepseek.key then
    return data.deepseek.key
  end
  return nil
end

local deepseek_key = get_deepseek_key()
if deepseek_key then
  vim.env.DEEPSEEK_API_KEY = deepseek_key
end

-- 延后 setup：AI ghost text 只在你按 <A-m> 之后才用得到，
-- 且 minuet 模块链约 15ms，不占启动时间
vim.schedule(function()
  vim.cmd.packadd("minuet-ai.nvim")
  local ok, minuet = pcall(require, "minuet")
  if not ok then return end
  if deepseek_key then
    minuet.setup({
      provider = "openai_fim_compatible",
      provider_options = {
        openai_fim_compatible = {
          api_key = "DEEPSEEK_API_KEY",
          name = "deepseek",
          optional = {
            max_tokens = 512,
            top_p = 0.9,
          },
        },
      },
      -- Virtual Text 模式（类 Copilot ghost text）
      virtualtext = {
        auto_trigger_ft = {},  -- 默认关闭，用 <A-m> 手动开启
        keymap = {
          accept = "<A-A>",       -- 接受整段补全
          accept_line = "<A-a>",  -- 接受一行
          accept_n_lines = "<A-z>", -- 接受 N 行
          prev = "<A-[>",         -- 上一个候选项
          next = "<A-]>",         -- 下一个候选项
          dismiss = "<A-e>",      -- 取消补全
        },
      },
      -- 不用 blink/cmp 前端
      add_single_line_entry = false,
      n_completions = 3,
      fetching_timeout = 2000,
    })
  else
    vim.notify("minuet: DeepSeek key not found in auth.json", vim.log.levels.WARN)
  end
end)
