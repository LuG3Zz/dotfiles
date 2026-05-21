#!/bin/bash
tmpfile=$(mktemp /tmp/ocrshot-XXXXXX.png)
tmpfile_big="${tmpfile%.png}@2x.png"
grim -g "$(slurp -b '#2E2A1E55' -c '#fb751bff')" "$tmpfile"
magick "$tmpfile" -scale 200% "$tmpfile_big"
cd /home/brownlu/Project/ocr
text=$(.venv/bin/python ocr.py "$tmpfile_big")
if [ -n "$text" ]; then
  echo "$text" | wl-copy
  notify-send "OCR 识别成功" "$(echo "$text" | head -c 200)"
else
  notify-send "OCR 识别失败" "未识别到文字"
fi
rm -f "$tmpfile" "$tmpfile_big"
