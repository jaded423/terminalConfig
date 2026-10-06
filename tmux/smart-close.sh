#!/usr/bin/env bash
# Smart-close a tmux session.
# If closing the session the CURRENT client is attached to, first switch that
# client to the most RECENT unattached session (fallback: most recent other
# session) so we land on the freshest work, not on a session already open in
# another terminal. Recent = last attached, or created if never attached.
# Killing any OTHER session just kills it — the client doesn't move.
#
# Usage: smart-close.sh [target-session]   (defaults to current session)
#        smart-close.sh --pick <target>    (print where a client would land; closes nothing)
# Called by: zsh `close`, tmux `prefix X` bind, sesh popup `Ctrl-d` bind.

# pick_next <target> <1 = unattached sessions only | 0 = any>
pick_next() {
  tmux list-sessions -F '#{session_last_attached}	#{session_created}	#{session_attached}	#{session_name}' \
    | awk -F'\t' -v c="$1" -v free="$2" '$4!=c && (!free || $3==0) {
        r = ($1+0 > $2+0) ? $1+0 : $2+0; print r "\t" $4 }' \
    | sort -t'	' -k1,1nr | head -1 | cut -f2-
}

if [ "$1" = "--pick" ]; then
  next=$(pick_next "$2" 1); [ -z "$next" ] && next=$(pick_next "$2" 0)
  echo "$next"; exit 0
fi

# The sesh popup hands over the session + client it was opened from (SESH_HERE /
# SESH_CLIENT): inside a popup tmux reports the most recently attached session of
# any terminal, not the one in front of Joshua.
client_session="${SESH_HERE:-$(tmux display-message -p '#{session_name}')}"
target="${1:-$client_session}"

# Only move a client when one is actually attached to the target. `close` typed
# by send-keys into an UNATTACHED session still reports that session as
# "current", and a bare switch-client then falls back to the most recent client
# anywhere — i.e. it yanks Joshua out of the session he is working in (2026-10-01).
attached="$(tmux display-message -p -t "=$target:" '#{session_attached}' 2>/dev/null)"

if [ "$target" = "$client_session" ] && [ "${attached:-0}" -gt 0 ]; then
  next=$(pick_next "$target" 1)
  [ -z "$next" ] && next=$(pick_next "$target" 0)
  [ -n "$next" ] && tmux switch-client ${SESH_CLIENT:+-c "$SESH_CLIENT"} -t "=$next"
fi

tmux kill-session -t "$target"
