#!/bin/bash
# smart_shot.sh — mango 版 Omarchy 智能截图
#   用法: smart_shot.sh [smart|windows|fullscreen]
#   smart(默认): 自由框选, <20px² 视为误点 → 自动吸附为包含它的窗口/整屏矩形
#   windows:     点哪吸哪(喂矩形列表给 slurp -r)
#   fullscreen:  聚焦窗口所在显示器整屏
# 流程: grim 保存到 ~/Pictures + wl-copy 进剪贴板 + 通知(带 satty 标注 / Mark Shot 编辑 按钮)

OUT_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
mkdir -p "$OUT_DIR"
FILE="$OUT_DIR/shot-$(date +%F_%H-%M-%S).png"

[ -n "$MANGO_INSTANCE_SIGNATURE" ] || export MANGO_INSTANCE_SIGNATURE="$(ls -t /run/user/$(id -u)/mango-*.sock | head -1)"

MON_GEO() { mmsg get all-monitors | jq -r '.monitors[] | "\(.x),\(.y) \(.width)x\(.height)"'; }
WIN_GEO() { mmsg get all-clients | jq -r '.clients[] | select(.is_visible == true and .width > 0) | "\(.x),\(.y) \(.width)x\(.height)"'; }

case "$1" in
fullscreen)
	MON="$(mmsg get all-clients | jq -r '.clients[] | select(.is_focused == true) | .monitor' | head -1)"
	[ -z "$MON" ] && MON="$(mmsg get all-monitors | jq -r '.monitors[] | select(.active == true) | .name' | head -1)"
	SEL="$(mmsg get all-monitors | jq -r --arg m "$MON" '.monitors[] | select(.name == $m) | "\(.x),\(.y) \(.width)x\(.height)"')"
	;;
windows)
	SEL="$( { MON_GEO; WIN_GEO; } | slurp -r 2>/dev/null)"
	;;
smart | *)
	RECTS="$( { MON_GEO; WIN_GEO; } )"
	SEL="$(echo "$RECTS" | slurp 2>/dev/null)"
	# 防误触: 选区太小 → 吸附到包含它的矩形 (窗口优先于整屏)
	if [[ $SEL =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]]; then
		if ((BASH_REMATCH[3] * BASH_REMATCH[4] < 20)); then
			cx=${BASH_REMATCH[1]} cy=${BASH_REMATCH[2]}
			best=""
			while IFS= read -r r; do
				[[ $r =~ ^([0-9]+),([0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]] || continue
				rx=${BASH_REMATCH[1]} ry=${BASH_REMATCH[2]} rw=${BASH_REMATCH[3]} rh=${BASH_REMATCH[4]}
				if ((cx >= rx && cx < rx + rw && cy >= ry && cy < ry + rh)); then
					if [ -z "$best" ] || ((rw * rh < best_w * best_h)); then
						best="$r" best_w=$rw best_h=$rh
					fi
				fi
			done <<<"$RECTS"
			[ -n "$best" ] && SEL="$best"
		fi
	fi
	;;
esac

[ -z "$SEL" ] && exit 0
grim -g "$SEL" "$FILE" || exit 1
wl-copy <"$FILE"

(
	ACTION=$(notify-send -a "mango" "截图已保存并复制" "$FILE" -i "$FILE" -t 10000 -A "satty=satty 标注" -A "mark=Mark Shot 编辑")
	case "$ACTION" in
	satty)
		satty --filename "$FILE" --output-filename "$FILE" \
			--actions-on-enter save-to-clipboard --save-after-copy --copy-command wl-copy
		;;
	mark)
		mark-shot "$FILE"
		;;
	esac
) >/dev/null 2>&1 &
exit 0
