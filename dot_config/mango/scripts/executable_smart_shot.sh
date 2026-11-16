#!/bin/bash
# smart_shot.sh — mango 智能截图 (裸按 Print 一键流)
#   默认: 自由框选(原有视觉样式) → <20px² 误点自动吸附包含它的窗口/整屏 → grim → 直接进 satty 标注
#   windows: 点哪吸哪(矩形列表) → 同上直进 satty
#   fullscreen: 聚焦显示器整屏 → 保存+复制+通知(带 satty/mark-shot 按钮)
# 其余键位: SUPER+Print=OCR, SUPER+ALT+Print=本脚本 fullscreen, SUPER+ALT+R=录屏

OUT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
mkdir -p "$OUT_DIR"
FILE="$OUT_DIR/shot-$(date +%F_%H-%M-%S).png"

[ -n "$MANGO_INSTANCE_SIGNATURE" ] || export MANGO_INSTANCE_SIGNATURE="$(ls -t /run/user/$(id -u)/mango-*.sock | head -1)"

MON_GEO() { mmsg get all-monitors | jq -r '.monitors[] | "\(.x),\(.y) \(.width)x\(.height)"'; }
WIN_GEO() { mmsg get all-clients | jq -r '.clients[] | select(.is_visible == true and .width > 0) | "\(.x),\(.y) \(.width)x\(.height)"'; }

snap_tiny() { # $1=选区, $2=候选矩形流 → 防误触吸附
	local sel=$1 rects=$2
	[[ $sel =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]] || { echo "$sel"; return; }
	if ((BASH_REMATCH[3] * BASH_REMATCH[4] >= 20)); then
		echo "$sel"
		return
	fi
	local cx=${BASH_REMATCH[1]} cy=${BASH_REMATCH[2]} best="" bw=0 bh=0
	while IFS= read -r r; do
		[[ $r =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]] || continue
		local rx=${BASH_REMATCH[1]} ry=${BASH_REMATCH[2]} rw=${BASH_REMATCH[3]} rh=${BASH_REMATCH[4]}
		if ((cx >= rx && cx < rx + rw && cy >= ry && cy < ry + rh)); then
			if [ -z "$best" ] || ((rw * rh < bw * bh)); then
				best="$r" bw=$rw bh=$rh
			fi
		fi
	done <<<"$rects"
	echo "${best:-$sel}"
}

case "$1" in
fullscreen)
	MON="$(mmsg get all-clients | jq -r '.clients[] | select(.is_focused == true) | .monitor' | head -1)"
	[ -z "$MON" ] && MON="$(mmsg get all-monitors | jq -r '.monitors[] | select(.active == true) | .name' | head -1)"
	SEL="$(mmsg get all-monitors | jq -r --arg m "$MON" '.monitors[] | select(.name == $m) | "\(.x),\(.y) \(.width)x\(.height)"')"
	grim -g "$SEL" "$FILE" || exit 1
	wl-copy <"$FILE"
	(
		ACTION=$(notify-send -a "mango" "截图已保存并复制" "$FILE" -i "$FILE" -t 10000 -A "satty=satty 标注" -A "mark=Mark Shot 编辑")
		{
			echo "=== $(date '+%T') ACTION=[$ACTION] FILE=$FILE WD=$WAYLAND_DISPLAY"
		} >>/tmp/smart-shot.log
		case "$ACTION" in
		satty)
			echo "launching satty" >>/tmp/smart-shot.log
			satty --filename "$FILE" --output-filename "$FILE" \
				--actions-on-enter save-to-clipboard --save-after-copy --copy-command wl-copy >>/tmp/smart-shot.log 2>&1
			echo "satty exited $?" >>/tmp/smart-shot.log
			;;
		mark)
			echo "launching mark-shot" >>/tmp/smart-shot.log
			mark-shot "$FILE" >>/tmp/smart-shot.log 2>&1
			;;
		*) echo "no branch for ACTION (timeout/expired)" >>/tmp/smart-shot.log ;;
		esac
	) >/dev/null 2>&1 &
	exit 0
	;;
windows)
	# 自由拖框模式 (挪回独立键): 原有视觉样式 + 防误触吸附
	SEL="$(slurp -b '#2E2A1E55' -c '#fb751bff' 2>/dev/null)"
	SEL="$(snap_tiny "$SEL" "$( { MON_GEO; WIN_GEO; } )")"
	;;
smart | *)
	# 主模式: 悬停即高亮所在矩形(slurp -r 原生反馈), 单击吸附
	# 矩形含整屏 → 点桌面空白 = 整屏截图; 自由拖框在 SUPER+SHIFT+Print
	SEL="$( { MON_GEO; WIN_GEO; } | slurp -r -s '#fb751bff' 2>/dev/null)"
	;;
esac

[ -z "$SEL" ] && exit 0
grim -g "$SEL" "$FILE" || exit 1
satty --filename "$FILE" --output-filename "$FILE" \
	--actions-on-enter save-to-clipboard --save-after-copy --copy-command wl-copy
