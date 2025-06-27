#!/bin/bash
# $HOME/.config/sway/scripts/random_wallpaper.sh

WALLPAPER_DIR="$HOME/wallpaper"

if [ -d "$WALLPAPER_DIR" ]; then
  wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.heic \) | shuf -n 1)
  if [ -n "$wallpaper" ]; then
    # swww img /path/to/image --transition-type <type> --transition-duration <seconds>
    # 常见的 transition-type: simple, fade, left, right, top, bottom, wipe, grow, outer
    swww img "$wallpaper" --transition-type random --transition-duration 1
  else
    echo "在 $WALLPAPER_DIR 中未找到壁纸图片。" >&2
  fi
else
  echo "壁纸目录 $WALLPAPER_DIR 不存在。" >&2
fi
