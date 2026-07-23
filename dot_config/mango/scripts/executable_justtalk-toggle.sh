#!/bin/bash
pids=$(pgrep -f "^/home/brownlu/\.local/bin/just-talk" 2>/dev/null)
if [ -n "$pids" ]; then
  echo "$pids" | xargs kill
  notify-send "JustTalk" "已关闭"
else
  /home/brownlu/.local/bin/just-talk -no-tui &
  notify-send "JustTalk" "已启动"
fi
