-- ~/.config/yazi/init.lua

-- 书签：不自动记录上次目录，不弹通知
require("bookmarks"):setup({
	last_directory = { enable = false },
	persist = "none",
	notify = { enable = false },
})

require("full-border"):setup({ type = ui.Border.ROUNDED })

-- 每行 git 状态（配合 yazi.toml 的 prepend_fetchers）
require("git"):setup()

-- 按扩展名判断 MIME（比读文件内容快）
require("mime-ext"):setup()

-- 状态栏：符号链接目标
Status:children_add(function(self)
	local h = self._current.hovered
	return h and h.link_to and (" -> " .. tostring(h.link_to)) or ""
end, 3300, Status.LEFT)

-- 状态栏：悬停文件的修改时间
Status:children_add(function(self)
	local h = self._current.hovered
	local time = h and math.floor(h.cha.mtime or 0) or 0
	if time == 0 then
		return ""
	end
	local fmt = os.date("%Y", time) == os.date("%Y") and "%b %d %H:%M" or "%Y-%m-%d"
	return ui.Line { ui.Span(os.date(fmt, time) .. " "):fg("blue") }
end, 500, Status.RIGHT)

-- starship 提示符
require("starship"):setup()
