#!/usr/bin/bash
# island_toggle.sh — SUPER+B: 岛模式下的 bar 隐藏/显示
#
# 背景: DMS 1.6.x 对 island 模式硬编码拦截全部 bar 可见性 IPC
#       (show/hide/toggle/autoHide 均 return "BAR_IS_ISLAND"), 岛的
#       DankIslandHostWindow 也不读取 visible/autoHide 字段。
# 可行路: island 宿主窗口由 barConfigs[].enabled 门控 (与"设置 → 岛
#       卡片"的开关同一路径), settings.json 是 watchChanges 实时热载,
#       所以直接改写文件即可整体隐藏/恢复岛, 不动 DMS 其他状态。
# 注意: 与 DMS 内本次会话内的其他设置修改存在极小竞窗, 正常使用无碍。

CFG="$HOME/.config/DankMaterialShell/settings.json"

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

ENABLED=$(python3 -c "import json;print(json.load(open('$CFG'))['barConfigs'][0]['enabled'])")
if [ "$ENABLED" = "True" ]; then
	notify-send -a "mango" "岛已恢复" "SUPER+B 再按一次可隐藏" &
else
	notify-send -a "mango" "岛已隐藏" "SUPER+B 再按一次恢复" &
fi
