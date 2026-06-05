# -----------------------------------------------------
# Key bindings
# -----------------------------------------------------

# ---- Vi mode settings (for zsh-vi-mode) ----
VI_MODE_SET_CURSOR=true
VI_MODE_HIGHLIGHT=false

# ---- History substring search (↑/↓) ----
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ---- Word jump (Ctrl+← / Ctrl+→) ----
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ---- Ctrl+F: FZF file search (no hidden files) ----
bindkey '^f' fzf-file-widget

# ---- Ctrl+\: toggle autosuggest accept/reject ----
bindkey '^\' autosuggest-toggle
