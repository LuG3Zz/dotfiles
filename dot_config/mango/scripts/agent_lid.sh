#!/usr/bin/bash
# agent_lid.sh — 合盖不停机模式 (跑 agent 时偶尔用)
#
# 问题: mango/DMS 都不管盖子, 合盖动作由 systemd-logind 处理,
#       默认 HandleLidSwitch=suspend 一合盖就睡; 且合盖后无输入,
#       10min 熄屏 / 2h 挂起定时器照常触发。
# 做法: systemd-inhibit 抑制锁挡住 logind 的盖子动作 (不动全局配置);
#       dms ipc inhibit 挡住 DMS 的空闲熄屏/挂起。
# 用法: agent_lid.sh          开/关切换
#       agent_lid.sh status   查询状态
# 安全阀: 6 小时后自动退出, 忘了关也不至于整夜掉电。

PIDFILE=/tmp/agent-lid-mode.pid
AUTO_UNLOCK_S=$((6 * 3600))

msg() {
	command -v notify-send >/dev/null && notify-send -a "mango" "合盖运行模式" "$1"
}

is_on() {
	[ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

if [ "$1" = "status" ]; then
	is_on && echo "ON  (pid $(cat "$PIDFILE"), 上限 ${AUTO_UNLOCK_S}s)" || echo "OFF"
	exit 0
fi

if is_on; then
	# 只杀持有抑制锁的 systemd-inhibit 进程, 其父 shell 会自动执行 dms disable
	pkill -f "systemd-inhibit --what=handle-lid-switch" 2>/dev/null
	dms ipc call inhibit disable
	rm -f "$PIDFILE"
	msg "OFF — 合盖恢复挂起, 空闲熄屏/挂起恢复"
else
	rm -f "$PIDFILE"
	# 父 shell: 抑制锁结束后自动解除 DMS 空闲抑制 (自动过期路径)
	nohup bash -c "systemd-inhibit --what=handle-lid-switch sleep ${AUTO_UNLOCK_S}; dms ipc call inhibit disable" >/dev/null 2>&1 &
	echo $! >"$PIDFILE"
	dms ipc call inhibit enable
	msg "ON — 现在合盖不停机; 6 小时后自动恢复, 再按一次立即恢复"
fi
