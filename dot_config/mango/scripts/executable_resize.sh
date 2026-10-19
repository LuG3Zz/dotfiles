#!/bin/bash
# resize wrapper: tiled → resizewin, floating → smartresizewin
dir=$1
floating=$(mmsg -g -f 2>/dev/null)
if [ "$floating" = "1" ]; then
  mmsg -d "smartresizewin,$dir"
else
  case "$dir" in
    left)  mmsg -d resizewin,-5,0 ;;
    down)  mmsg -d resizewin,0,+5 ;;
    up)    mmsg -d resizewin,0,-5 ;;
    right) mmsg -d resizewin,+5,0 ;;
  esac
fi
