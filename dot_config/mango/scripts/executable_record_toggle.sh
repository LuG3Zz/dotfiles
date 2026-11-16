#!/bin/bash
# record_toggle.sh — 录屏开关 (SUPER+ALT,R)
# 开始: wf-recorder 写 ~/Videos/rec-*.mp4 (聚焦显示器)
# 结束: SIGINT 优雅收尾 (文件自动 finalize), 通知路径

VIDDIR="$HOME/Videos"
mkdir -p "$VIDDIR"

[ -n "$MANGO_INSTANCE_SIGNATURE" ] || export MANGO_INSTANCE_SIGNATURE="$(ls -t /run/user/$(id -u)/mango-*.sock | head -1)"

if pgrep -x wf-recorder >/dev/null 2>&1; then
	pkill -INT -x wf-recorder
	sleep 0.6
	LAST="$(ls -t "$VIDDIR"/rec-*.mp4 2>/dev/null | head -1)"
	notify-send -a "mango" "录屏已停止" "${LAST:-$(basename "$LAST" 2>/dev/null)}"
else
	MON="$(mmsg get all-clients | jq -r '.clients[] | select(.is_focused == true) | .monitor' | head -1)"
	[ -z "$MON" ] && MON="$(mmsg get all-monitors | jq -r '.monitors[] | select(.active == true) | .name' | head -1)"
	setsid wf-recorder -o "$MON" -f "$VIDDIR/rec-$(date +%F_%H-%M-%S).mp4" >/dev/null 2>&1 &
	notify-send -a "mango" "录屏开始" "$MON · SUPER+ALT+R 停止"
fi
