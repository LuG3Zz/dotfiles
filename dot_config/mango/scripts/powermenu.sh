#!/usr/bin/env bash
# 电源菜单: fuzzel 选择 → systemctl / loginctl / dms 执行
set -euo pipefail

entries="关机\n重启\n挂起\n锁定\n注销"

choice=$(printf '%b' "$entries" | fuzzel --dmenu --prompt="电源: " --lines=5)

case "$choice" in
  关机) systemctl poweroff ;;
  重启) systemctl reboot ;;
  挂起) systemctl suspend ;;
  锁定) dms ipc call lock lock ;;
  注销)
    if [ -n "${XDG_SESSION_ID:-}" ]; then
      loginctl terminate-session "$XDG_SESSION_ID"
    else
      loginctl terminate-user "$USER"
    fi
    ;;
  *) exit 0 ;;
esac