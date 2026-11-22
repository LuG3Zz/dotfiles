-- 插件二分开关（临时排查用，正常使用不会生效）
--
-- 用法：
--   NVIM_DISABLE="smear-cursor.nvim,lualine.nvim" nvim 文件
--
-- 名字用 lazy-lock.json 里的名字。它只是给这些插件的 spec 打上
-- enabled = false，lazy.nvim 会按名字合并覆盖。
local names = vim.split(vim.env.NVIM_DISABLE or "", ",", { trimempty = true })
if #names == 0 then
  return {}
end

local specs = {}
for _, name in ipairs(names) do
  specs[#specs + 1] = { name, enabled = false }
end
return specs
