#!/usr/bin/env zsh
SESSION="remote"

# Window 1: Book5 (Proxmox node)
tmux rename-window -t "$SESSION" "Book5"
tmux send-keys -t "$SESSION:Book5" "ssh book5 -t 'zsh -ic t'" Enter

# Window 2: Omarchy (VM on book5)
tmux new-window -t "$SESSION" -n "Omarchy"
tmux send-keys -t "$SESSION:Omarchy" "ssh omarchy -t 'zsh -ic t'" Enter

# Window 3: Tower (Proxmox node)
tmux new-window -t "$SESSION" -n "Tower"
tmux send-keys -t "$SESSION:Tower" "ssh tower -t 'zsh -ic t'" Enter

# Window 4: Ubuntu (VM on tower)
tmux new-window -t "$SESSION" -n "Ubuntu"
tmux send-keys -t "$SESSION:Ubuntu" "ssh ubuntu -t 'zsh -ic t'" Enter

# Window 5: Dax
tmux new-window -t "$SESSION" -n "Dax"
tmux send-keys -t "$SESSION:Dax" "ssh dax" Enter

# Select first window
tmux select-window -t "$SESSION:Book5"
