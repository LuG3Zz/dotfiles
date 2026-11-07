#!/usr/bin/bash
# img_open.sh — 文件管理器双击图片的画廊打开器
#   选中 1 张      → 打开其所在文件夹的画廊（thumb 网格, Enter 进单图）
#   选中 N 张      → 画廊直接呈现所选的 N 张
#   传入目录       → 直接该目录画廊
#   什么都没传     → 当前目录画廊
if [ "$#" -eq 0 ]; then
	exec swayimg -g "$PWD"
fi
if [ "$#" -eq 1 ] && [ -d "$1" ]; then
	exec swayimg -g "$1"
fi
if [ "$#" -eq 1 ]; then
	exec swayimg -g "$(dirname "$1")"
fi
exec swayimg -g "$@"
