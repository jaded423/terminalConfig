#!/usr/bin/env zsh
SESSION="btop"

tmux rename-window -t "$SESSION" "btop"

# The original sesh pane will become book5.
P_BOOK5=$(tmux display-message -p -t "$SESSION" '#{pane_id}')

# Each new pane is launched directly with its alias command. No send-keys,
# no shell-readiness race, no resize-during-startup races — the pane is
# created at its final size and the command starts immediately.
#
#   pane layout:
#     book5    | tower
#     omarchy  | ubuntu
P_TOWER=$(tmux   split-window -h -t "$P_BOOK5" -P -F '#{pane_id}' "zsh -ic 'tower'")
P_OMARCHY=$(tmux split-window -v -t "$P_BOOK5" -P -F '#{pane_id}' "zsh -ic 'omarchy'")
P_UBUNTU=$(tmux  split-window -v -t "$P_TOWER" -P -F '#{pane_id}' "zsh -ic 'ubuntu'")

# Replace book5's idle shell with the command. -k kills the existing zsh.
tmux respawn-pane -k -t "$P_BOOK5" "zsh -ic 'book5'"

tmux select-pane -t "$P_BOOK5"
