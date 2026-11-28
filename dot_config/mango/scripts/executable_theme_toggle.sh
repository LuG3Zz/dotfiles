#!/bin/bash
# theme_toggle.sh — 切 DMS 深浅主题并立即同步 GTK 主题
# DMS 的 toggle 是异步落地: 立刻 getMode 会读到旧值, 稍等再同步
dms ipc call theme toggle
sleep 1
exec "$HOME/.config/mango/scripts/gtk_theme_sync.sh"
