#!/usr/bin/env bash
# tmux status-right internet indicator (tmux.conf `#(…/net-status.sh)`).
# Prints the whole styled segment, so tmux never decides on/off from an empty job result.
# - Turns red only after 2 failed checks in a row; one lost ping keeps "on".
# - tmux runs #() jobs once PER ATTACHED CLIENT, so two clients fire two pings within
#   milliseconds. On the Be Well PC (WSL mirrored networking) the second back-to-back
#   ping never gets a reply — that was the 2026-11-15 blink. Both jobs start in the
#   same instant, so a lock makes the second wait for the first, then a result younger
#   than 4 s is reused instead of pinging again.
state="${XDG_RUNTIME_DIR:-/tmp}/tmux-net-$(id -u)"   # "<epoch> <consecutive fails>"
exec 9>"$state.lock"
flock -w 4 9
now=$(date +%s)
{ read -r last fails <"$state"; } 2>/dev/null || { last=0; fails=0; }
if [ $((now - ${last:-0})) -ge 4 ]; then
  if ping -c1 -W2 www.google.com >/dev/null 2>&1; then
    fails=0
  else
    fails=$(( ${fails:-0} + 1 ))
  fi
  echo "$(date +%s) $fails" >"$state"
fi
if [ "${fails:-0}" -lt 2 ]; then
  echo "#[fg=$(tmux show -gv @thm_mauve)] 󰖩 on "
else
  echo "#[fg=$(tmux show -gv @thm_red)] 󰖪 off "
fi
