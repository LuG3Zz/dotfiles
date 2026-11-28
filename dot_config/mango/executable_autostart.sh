#!/bin/bash

set +e

# polkit 图形授权 agent (pkexec/系统的提权弹窗; DMS 自身不注册 agent)
/usr/lib/polkit-kde-authentication-agent-1 >/dev/null 2>&1 &

# GTK 主题跟随 DMS(明暗+强调色)
~/.config/mango/scripts/gtk_theme_sync.sh --watch >/dev/null 2>&1 &

# dms
dms run >/dev/null 2>&1 &

# ime
fcitx5 --replace -d >/dev/null 2>&1 &

# clipboard history
wl-paste --type text --watch cliphist store >/dev/null 2>&1 &
