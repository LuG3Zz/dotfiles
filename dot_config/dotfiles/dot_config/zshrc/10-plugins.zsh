# -----------------------------------------------------
# Manual plugin loader (no framework)
# -----------------------------------------------------

ZSH_PLUGIN_DIR="$XDG_DATA_HOME/zsh/plugins"

plugins=(
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-history-substring-search"
  "jeffreytse/zsh-vi-mode"
)

for plugin in $plugins; do
  local plugin_name="${plugin:t}"
  local plugin_dir="$ZSH_PLUGIN_DIR/$plugin_name"

  if [[ ! -d "$plugin_dir" ]]; then
    echo "Installing plugin: $plugin_name..."
    git clone --depth 1 "https://github.com/$plugin.git" "$plugin_dir"
  fi

  source "$plugin_dir/$plugin_name.zsh" 2>/dev/null || \
  source "$plugin_dir/${plugin_name}.plugin.zsh" 2>/dev/null
done

# Update function for manual plugin updates
zplugin-update() {
  for plugin_dir in "$ZSH_PLUGIN_DIR"/*/; do
    echo "Updating $(basename $plugin_dir)..."
    git -C "$plugin_dir" pull
  done
}
