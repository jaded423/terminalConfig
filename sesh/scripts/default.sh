#!/usr/bin/env zsh
SESSION=$(tmux display-message -p '#S')
tmux rename-window -t "$SESSION" "Main"
tmux new-window -t "$SESSION" -n "Claude"
tmux send-keys -t "$SESSION:Claude" "claude" Enter
tmux new-window -t "$SESSION" -n "Neo"
tmux send-keys -t "$SESSION:Neo" "nvim" Enter
tmux select-window -t "$SESSION:Main"
clear
