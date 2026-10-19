#!/usr/bin/bash
# bar_toggle.sh — SUPER+B: 隐藏/显示 bar (岛模式与普通模式通吃)
#
# DMS 1.6.x 对 island 模式硬编码拦截全部 bar 可见性 IPC
# (show/hide/toggle/until 均返回 "BAR_IS_ISLAND"), 且 DankIslandHostWindow
# 不读取 visible/autoHide。但两条路各自可用:
# - island=true : island 宿主由 barConfigs[].enabled 门控 (设置页岛卡片
#   开关同一路径), settings.json 被 watchChanges 实时热载 → 翻文件
# - island=false: 标准的 bar toggle IPC 直接可用 → 走官方通道
# 每次按键读取当前 is_island 判断该走哪条, 两种模式来回切都正确。

CFG="$HOME/.config/DankMaterialShell/settings.json"

IS_ISLAND=$(python3 - "$CFG" <<'EOF'
import json, sys
print(json.load(open(sys.argv[1]))["barConfigs"][0].get("island", False))
EOF
) || { echo "settings.json 不可读" >&2; exit 1; }

if [ "$IS_ISLAND" = "True" ]; then
	python3 - "$CFG" <<'EOF' || { echo "settings.json 结构异常, 未改动" >&2; exit 1; }
import json, sys
path = sys.argv[1]
cfg = json.load(open(path))
bars = cfg.get("barConfigs")
if not bars:
	sys.exit(1)
bar = bars[0]
bar["enabled"] = not bar.get("enabled", True)
json.dump(cfg, open(path, "w"), indent=2, ensure_ascii=False)
EOF
else
	dms ipc call bar toggle index 0 >/dev/null 2>&1 || { echo "bar toggle IPC 失败" >&2; exit 1; }
fi

# 统一语义: (enabled 且 visible) = 可见, 据此提示
SHOWN=$(python3 - "$CFG" <<'EOF'
import json, sys
b = json.load(open(sys.argv[1]))["barConfigs"][0]
print(bool(b.get("enabled", True)) and bool(b.get("visible", True)))
EOF
)
if [ "$SHOWN" = "True" ]; then
	notify-send -a "mango" "bar 已显示" "SUPER+B 再按一次隐藏" &
else
	notify-send -a "mango" "bar 已隐藏" "SUPER+B 再按一次恢复" &
fi
