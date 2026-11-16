#!/usr/bin/env bash
# tmux status-right internet indicator (tmux.conf `#(…/net-status.sh)`).
# Prints the whole styled segment, so tmux never has to decide on/off from an empty
# job result (the old inline `#{?#(ping …),on,off}` painted "off" whenever the job
# output was empty, which blinked on the Be Well PC, 2026-11-15).
# Turns red only after 2 failed pings in a row; one lost ping keeps "on".
state="${XDG_RUNTIME_DIR:-/tmp}/tmux-net-fails-$(id -u)"
fails=$(cat "$state" 2>/dev/null || echo 0)
if ping -c1 -W2 www.google.com >/dev/null 2>&1; then
  fails=0
else
  fails=$((fails + 1))
fi
echo "$fails" >"$state"
if [ "$fails" -lt 2 ]; then
  echo "#[fg=$(tmux show -gv @thm_mauve)] 󰖩 on "
else
  echo "#[fg=$(tmux show -gv @thm_red)] 󰖪 off "
fi
