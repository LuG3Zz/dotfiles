#!/bin/bash
# gtk_theme_sync.sh [--watch] — 让 GTK4/GTK3 主题跟随 DMS
#   明暗:  dms theme getMode → Catppuccin Mocha(dark) / Latte(light) + gsettings color-scheme
#   强调:  DMS 动态主题生成的 focus_color(随壁纸刷新) → 追加 @define-color accent_*
#   --watch: 后台每 60s 对齐一次(应对 DMS 自动切换/动态换色)
set -u

B="$HOME/.config/gtk-4.0"
G3="$HOME/.config/gtk-3.0"
COLORS="$HOME/.config/mango/dms/colors.conf"

apply_once() {
	local mode variant accent tmp_g4 tmp_g3 scheme
	mode="$(dms ipc call theme getMode 2>/dev/null | tail -1)"
	if [ "$mode" = "light" ]; then
		variant="latte" scheme="prefer-light"
	else
		variant="mocha" scheme="prefer-dark"
	fi

	# DMS 调色板里的强调色（随壁纸变化）
	accent="$(grep -oE 'focus_color[[:space:]]*=[[:space:]]*0x[0-9a-fA-F]{6}' "$COLORS" 2>/dev/null | grep -oE '[0-9a-fA-F]{6}$' | head -1)"

	# GTK4: 变体 CSS + accent 注入
	tmp_g4="$(cat "$B/variants/$variant/gtk.css" 2>/dev/null)"
	if [ -n "$accent" ]; then
		tmp_g4="$tmp_g4
/* DMS accent sync */
@define-color accent_color #$accent;
@define-color accent_bg_color #$accent;
"
	fi
	if ! printf '%s' "$tmp_g4" | cmp -s - "$B/gtk.css" 2>/dev/null; then
		[ -d "$B/variants/$variant/assets" ] && cp -r "$B/variants/$variant/assets" "$B/" 2>/dev/null
		printf '%s' "$tmp_g4" >"$B/gtk.css"
	fi

	# GTK3: 同步变体（accent 注入同理）
	tmp_g3="$(cat "$G3/variants/$variant/gtk.css" 2>/dev/null)"
	if [ -n "$accent" ]; then
		tmp_g3="$tmp_g3
@define-color theme_selected_bg_color #$accent;
"
	fi
	if [ -n "$tmp_g3" ] && ! printf '%s' "$tmp_g3" | cmp -s - "$G3/gtk.css" 2>/dev/null; then
		[ -d "$G3/variants/$variant/assets" ] && cp -r "$G3/variants/$variant/assets" "$G3/" 2>/dev/null
		printf '%s' "$tmp_g3" >"$G3/gtk.css"
	fi

	gsettings set org.gnome.desktop.interface color-scheme "$scheme" 2>/dev/null
}

if [ "${1:-}" = "--watch" ]; then
	while true; do
		apply_once
		sleep 10
	done
else
	apply_once
fi
