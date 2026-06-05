#!/bin/bash
# Cliamp scratchpad for tmux
# Toggle a persistent cliamp session in a tmux popup window.
# Close the popup → music keeps playing.
# Press the key again → popup reopens.

SESSION="cliamp"

# If the session doesn't exist at all, create it (detached)
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux new-session -d -s "$SESSION" -x 80 -y 24 "cliamp"
    sleep 0.3
fi

# Open a popup attached to the scratchpad session
tmux display-popup -E -w 40% -h 60% "tmux attach-session -t '$SESSION'"
