#!/bin/bash

# ===================================================================
#   Rofi Power Menu (适配您现有主题的最终版)
# ===================================================================

# --- 图标定义 (Nerd Fonts) ---
LOCK_ICON=""
LOGOUT_ICON=""
SUSPEND_ICON=""
REBOOT_ICON=""
SHUTDOWN_ICON=""

# --- Rofi 选项 ---
# 我们不再在脚本中定义颜色，只提供纯文本和元数据
# `\0meta` 用于给 Rofi 主题提供线索，以便应用不同的样式
options="$LOCK_ICON Lock\0meta\x1fentry\x1flock"
options+="\n$LOGOUT_ICON Logout\0meta\x1fentry\x1flogout"
options+="\n$SUSPEND_ICON Suspend\0meta\x1fentry\x1fsuspend"
options+="\n$REBOOT_ICON Reboot\0meta\x1fentry\x1freboot"
options+="\n$SHUTDOWN_ICON Shutdown\0meta\x1fentry\x1fshutdown"

# --- 主逻辑 ---
# -theme-str: 动态地向 Rofi 传递一些额外的 CSS 样式
# 我们将使用它来专门为电源菜单调整布局
# 注意：我们不再使用 -theme 参数，因为它会覆盖您的主 Rofi 配置
chosen="$(
  echo -e "$options" | rofi -dmenu -p "Power" -i -l 5 \
    -theme-str 'window {width: 25%; location: center; y-offset: -50px;}' \
    -theme-str 'listview {lines: 5; columns: 1;}' \
    -theme-str 'inputbar {enabled: false;}'
)"

# 如果用户按 ESC 取消，则退出
if [ -z "$chosen" ]; then
  exit 0
fi

# case 语句直接匹配纯文本即可
case "$chosen" in
"$LOCK_ICON Lock")
  swaylock -f -c 000000
  ;;
"$LOGOUT_ICON Logout")
  mmsg -d quit
  ;;
"$SUSPEND_ICON Suspend")
  systemctl suspend
  ;;
"$REBOOT_ICON Reboot")
  systemctl reboot
  ;;
"$SHUTDOWN_ICON Shutdown")
  systemctl poweroff
  ;;
esac
