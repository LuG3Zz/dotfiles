-- ~/.config/yazi/init.lua

require("bookmarks"):setup({
	last_directory = { enable = false, persist = false, mode = "dir" },
	persist = "none",
	desc_format = "full",
	file_pick_mode = "hover",
	custom_desc_input = false,
	notify = {
		enable = false,
		timeout = 1,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})

require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

-- git 状态列（M/A/? 等，配合 yazi.toml 的 prepend_fetchers）
require("git"):setup({
	order = 1500,
})

-- MIME 类型按扩展名判断（比默认读文件内容快，牺牲少量准确性）
require("mime-ext"):setup()

-- 状态栏显示符号链接目标
Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)

-- 状态栏显示悬停文件的修改时间（joelazar 配置里的做法）
Status:children_add(function(self)
	local h = self._current.hovered
	if not h then
		return ""
	end
	local time = math.floor((h.cha.mtime or 0) / 1)  -- mtime 已是秒
	if time == 0 then
		return ""
	end
	local fmt = os.date("%Y", time) == os.date("%Y") and "%b %d %H:%M" or "%Y-%m-%d"
	return ui.Line { ui.Span(os.date(fmt, time) .. " "):fg("blue") }
end, 500, Status.RIGHT)

-- starship 提示符集成（git 分支等信息显示在状态栏）
require("starship"):setup()
