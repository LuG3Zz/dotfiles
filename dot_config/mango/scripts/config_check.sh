#!/bin/bash

# 获取mango命令输出并清理格式
output=$(mango -p 2>&1 | sed -r '
    s/\x1b\[[0-9;]*[a-zA-Z]//g   # 移除ANSI颜色代码
    s/   ╰─/ ╰─/g                # 压缩多余空格
    s/^[[:space:]]*//            # 删除行首空格
    s/[[:space:]]*$//            # 删除行尾空格
')

# 设置通知图标
icon="$HOME/.config/mango/wallpaper/mango.png"

# 重载配置
mmsg dispatch reload_config

# 根据是否有错误发送不同通知
if [[ -z "$output" ]]; then
    notify-send --urgency=low --icon="$icon" "Mango Status" "配置检查通过，已重载"
else
    notify-send --urgency=critical --icon="$icon" "Mango Status" "$output"
fi