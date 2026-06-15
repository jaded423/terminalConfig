#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:$PATH"

session=$(sesh list -i --hide-duplicates | fzf --ansi --no-sort --height=100% \
  --border --border-label ' sesh ' \
  --prompt '  ' \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-a:change-prompt(  )+reload(sesh list -i --hide-duplicates)' \
  --bind 'ctrl-t:change-prompt(  )+reload(sesh list -it)' \
  --bind 'ctrl-x:change-prompt(  )+reload(sesh list -iz)' \
  --bind 'ctrl-g:change-prompt(  )+reload(sesh list -ic)' \
  --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
  --bind 'ctrl-d:execute(~/.config/tmux/smart-close.sh {2..})+reload(sesh list -i --hide-duplicates)' \
  --preview-window 'right:70%' \
  --preview-label ' C-a all / C-t tmux / C-x zoxide / C-g config / C-f find / C-d kill ' \
  --preview-label-pos 'bottom' \
  --preview 'sesh preview {}')

[ -n "$session" ] && sesh connect "$session"
