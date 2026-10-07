#!/usr/bin/env bash
# fzf preview for the sesh picker (sesh.sh).
# A tmux pane is text, not pixels: it cannot be scaled down to fit, only cropped. `sesh preview`
# shows the TOP-LEFT corner of the pane; this shows the vertical MIDDLE instead, cut to the
# preview window's exact height (fzf exports FZF_PREVIEW_LINES to the preview command).
# Rows that are not a live tmux session (zoxide dirs, config sessions, fd results) go to sesh.
#
# Usage: sesh-preview.sh "<row as sesh list -i prints it>"

row="$1"
name="${row#* }" # drop the icon column; a bare path (ctrl-f rows) has no space and stays whole

if tmux has-session -t "=$name" 2>/dev/null; then
  height=$(tmux display -p -t "$name" '#{pane_height}')
  lines=${FZF_PREVIEW_LINES:-$height}
  if ((height > lines)); then
    start=$(((height - lines) / 2))
    tmux capture-pane -ep -t "$name" -S "$start" -E "$((start + lines - 1))"
  else
    tmux capture-pane -ep -t "$name"
  fi
else
  sesh preview "$row"
fi
