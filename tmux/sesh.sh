#!/usr/bin/env bash
# sesh picker (tmux popup, prefix S).
# The session this popup was opened FROM is always the first row and is named in
# the border label. sesh orders tmux sessions by last-attached across EVERY
# terminal, so with two terminals open the top row used to be whichever session
# was touched last anywhere — and C-d closed the wrong one (2026-10-06).
# SESH_HERE / SESH_CLIENT come from the tmux binding (tmux.conf `bind S`); a popup
# cannot work them out itself. smart-close.sh (C-d) reads the same two.
#
# Usage: sesh.sh                    (the picker)
#        sesh.sh --list [sesh flags] (the rows, current session first; used by reload)

if [ "$1" = "--list" ]; then
  shift
  sesh list -i "$@" | awk -v here="$SESH_HERE" '
    { name = $0; gsub(/\033\[[0-9;]*m/, "", name); sub(/^[^ ]+ /, "", name)
      if (here != "" && name == here && first == "") first = $0; else rest[n++] = $0 }
    END { if (first != "") print first; for (i = 0; i < n; i++) print rest[i] }'
  exit 0
fi

export SESH_HERE="${SESH_HERE:-$(tmux display-message -p '#{session_name}')}"
self="$HOME/.config/tmux/sesh.sh"

session=$("$self" --list --hide-duplicates | fzf --ansi --no-sort --height=100% \
  --border --border-label " sesh · you are in: $SESH_HERE " \
  --prompt '  ' \
  --bind 'tab:down,btab:up' \
  --bind "ctrl-a:change-prompt(  )+reload($self --list --hide-duplicates)" \
  --bind "ctrl-t:change-prompt(  )+reload($self --list -t)" \
  --bind 'ctrl-x:change-prompt(  )+reload(sesh list -iz)' \
  --bind 'ctrl-g:change-prompt(  )+reload(sesh list -ic)' \
  --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
  --bind "ctrl-d:execute(~/.config/tmux/smart-close.sh {2..})+reload($self --list --hide-duplicates)" \
  --preview-window 'right:70%' \
  --preview-label ' C-a all / C-t tmux / C-x zoxide / C-g config / C-f find / C-d kill ' \
  --preview-label-pos 'bottom' \
  --preview '~/.config/tmux/sesh-preview.sh {}')

[ -n "$session" ] && sesh connect "$session"
# Always 0: Esc (nothing picked) is not an error, and run-shell prints any
# non-zero exit into the pane as "… returned 1".
exit 0
