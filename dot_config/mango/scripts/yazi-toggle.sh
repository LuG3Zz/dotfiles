#!/bin/bash

# 检查 yazi 是否已在运行
if ! pgrep -f "alacritty.*yaziscratch" > /dev/null; then
    alacritty --class yaziscratch -e tmux new-session -A -s yazi yazi &
    disown
    sleep 0.3
fi

# 切换特殊标签0
mmsg dispatch toggle_special_tag
