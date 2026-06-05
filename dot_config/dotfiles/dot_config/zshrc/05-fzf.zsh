# -----------------------------------------------------
# FZF — fuzzy finder
# -----------------------------------------------------

# Source FZF shell integration (key bindings + completion)
source <(fzf --zsh 2>/dev/null)

# Default options
# --tmux: open in tmux popup when inside tmux, fall back to normal mode otherwise
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --tmux --inline-info"

# Ctrl+T: search files (including hidden), preview with bat
export FZF_CTRL_T_COMMAND="fd --hidden --strip-cwd-prefix 2>/dev/null || find ."
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"

# Alt+C: search directories (including hidden), preview tree
export FZF_ALT_C_COMMAND="fd --type d --hidden --strip-cwd-prefix 2>/dev/null || find . -type d"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} 2>/dev/null | head -50 || ls {}'"

# Ctrl+R: search history with preview (--tiebreak=index keeps most recent first)
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:wrap --tiebreak=index"
