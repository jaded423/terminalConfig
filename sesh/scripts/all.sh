#!/usr/bin/env zsh
# all.sh <go|multi> — one tmux window per ACCOUNT on that box, each attached to that account's own tmux.
# Shared boxes have one ssh alias per account (<host>-<user>, sshConfig): go + go-kid today; multi-verse
# now, + multi-kid once the kid gate lands (~/.claude/plans/global.kid-gate.pot-plan.md). Used by the
# sesh sessions "all-go" / "all-multi": attach wherever the kids are and help.
machine=${1:?usage: all.sh go|multi}
case $machine in
  go)    hosts=(go go-kid) ;;
  multi) hosts=(multi-verse) ;;     # add multi-kid here when that account exists
  *)     echo "usage: all.sh go|multi" >&2; exit 1 ;;
esac
SESSION="all-$machine"
first=1
for h in $hosts; do
  if (( first )); then tmux rename-window -t "$SESSION" "$h"; first=0
  else tmux new-window -t "$SESSION" -n "$h"; fi
  # kid accounts run bash, so no `zsh -ic t`: attach to their tmux, or start one
  tmux send-keys -t "$SESSION:$h" "ssh $h -t 'tmux attach 2>/dev/null || tmux new'" Enter
done
tmux select-window -t "$SESSION:${hosts[1]}"
