#!/bin/bash
# Autostart script for maomaowm

# 确保脚本不会因为某个命令失败而退出
set +e

# 延迟以确保 maomao 完全启动
sleep 1

# 屏幕锁定和电源管理
# swayidle -w \
#   timeout 300 'swaylock -f -c 000000' \
#   timeout 600 'swaymsg "output * dpms off"' \
#   resume 'swaymsg "output * dpms on"' \
#   before-sleep 'swaylock -f -c 000000' &

# idle to lightdown and shutdown screen
~/.config/maomao/scripts/idle.sh &

# 系统托盘与后台服务
nm-applet --indicator &
blueman-applet &
fcitx5 -d &
dunst &
mpdris2-rs &
clash-verge &
gammastep &
copyq &

# 壁纸 (使用 swww)
swww-daemon &
sleep 2 # 等待 daemon 启动
$HOME/.config/scroll/scripts/random_wallpaper.sh &

# 状态栏
waybar &

# 剪贴板历史和持久化
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
wl-clip-persist --clipboard regular &

# 认证代理
# 如果 /usr/lib/xfce-polkit/xfce-polkit 不存在，请替换为您的 polkit 代理
# 例如：/usr/lib/polkit-kde-authentication-agent-1
/usr/lib/xfce-polkit/xfce-polkit &

# 导入 dbus 环境变量
systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK &
hash dbus-update-activation-environment 2>/dev/null &&
  dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK &

# 屏幕共享/录制支持
/usr/lib/xdg-desktop-portal-wlr &
