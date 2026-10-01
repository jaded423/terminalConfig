#!/usr/bin/env bash
# Smart-close a tmux session.
# If closing the session the CURRENT client is attached to, first switch that
# client to the oldest UNATTACHED session (fallback: oldest other session) so
# we don't land on a session already open in another terminal.
# Killing any OTHER session just kills it — the client doesn't move.
#
# Usage: smart-close.sh [target-session]   (defaults to current session)
# Called by: tmux `prefix X` bind, sesh popup `Ctrl-d` bind.
export PATH="/opt/homebrew/bin:$PATH"

client_session="$(tmux display-message -p '#{session_name}')"
target="${1:-$client_session}"

# Only move a client when one is actually attached to the target. `close` typed
# by send-keys into an UNATTACHED session still reports that session as
# "current", and a bare switch-client then falls back to the most recent client
# anywhere — i.e. it yanks Joshua out of the session he is working in (2026-10-01).
attached="$(tmux display-message -p -t "=$target:" '#{session_attached}' 2>/dev/null)"

if [ "$target" = "$client_session" ] && [ "${attached:-0}" -gt 0 ]; then
  next=$(tmux list-sessions -F '#{session_created} #{session_attached} #{session_name}' \
    | awk -v c="$target" '$3!=c' | sort -n \
    | awk '$2==0{ $1=""; $2=""; sub(/^  /,""); print; exit }')
  [ -z "$next" ] && next=$(tmux list-sessions -F '#{session_created} #{session_name}' \
    | awk -v c="$target" '$2!=c' | sort -n | head -1 | cut -d' ' -f2-)
  [ -n "$next" ] && tmux switch-client -t "$next"
fi

tmux kill-session -t "$target"
