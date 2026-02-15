#!/bin/bash

# 配置文件和输出临时文件
CONFIG_DIR="$HOME/.config/mango"
MAIN_CONFIG="$CONFIG_DIR/bind.conf" # 根据你的实际主配置文件名调整
TEMP_FILE="/tmp/mangowc_cheatsheet.txt"

# 颜色定义（可选，用于终端显示）
HEADER_COLOR="\033[1;34m"
RESET_COLOR="\033[0m"

# 清空临时文件
>"$TEMP_FILE"

# 递归解析 source 文件并提取绑定
function parse_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return
  fi

  # 读取文件，去除注释和空行，提取 bind/mousebind/axisbind 行
  while IFS= read -r line; do
    # 去除行内注释（#后面的内容），但保留引号内的部分（这里简化处理，假设注释独立成行）
    line="${line%%#*}"
    # 跳过空行
    [[ -z "$line" ]] && continue

    # 处理 source 指令
    if [[ "$line" =~ ^source=(.+) ]]; then
      sub_file="${BASH_REMATCH[1]}"
      # 处理相对路径：如果以 ./ 开头，则相对于当前文件目录；否则可能是绝对路径或相对于主目录
      if [[ "$sub_file" =~ ^\./ ]]; then
        sub_file="$(dirname "$file")/${sub_file#./}"
      elif [[ "$sub_file" != /* ]]; then
        sub_file="$CONFIG_DIR/$sub_file"
      fi
      parse_file "$sub_file"
      continue
    fi

    # 提取 bind, mousebind, axisbind 行
    if [[ "$line" =~ ^(bind|mousebind|axisbind)=(.+)$ ]]; then
      type="${BASH_REMATCH[1]}"
      rest="${BASH_REMATCH[2]}"
      # 将行写入临时文件，格式化为易读的表格
      echo -e "$type\t$rest" >>"$TEMP_FILE"
    fi
  done <"$file"
}

# 开始解析主配置文件
parse_file "$MAIN_CONFIG"

# 检查是否提取到内容
if [[ ! -s "$TEMP_FILE" ]]; then
  echo "未找到任何绑定配置。" >"$TEMP_FILE"
fi

# 显示方式选择：可以终端分页显示，也可以用 rofi 显示
# 这里提供两种选项，通过命令行参数控制：./cheatsheet.sh [rofi|term]
display_mode="${1:-term}"

if [[ "$display_mode" == "rofi" ]]; then
  # 使用 rofi 显示（需要安装 rofi）
  # 将临时文件内容转换为 rofi 可读的格式（去掉制表符，用空格对齐）
  column -t -s $'\t' "$TEMP_FILE" | rofi -dmenu -p "Mangowc 按键速查" -i -markup-rows
else
  # 终端显示，使用 less 分页
  {
    echo -e "${HEADER_COLOR}Mangowc 按键绑定速查表${RESET_COLOR}\n"
    echo "类型    按键组合             动作/命令"
    echo "----------------------------------------"
    column -t -s $'\t' "$TEMP_FILE"
  } | less -R
fi
