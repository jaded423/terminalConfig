#!/usr/bin/env bash
# fzf preview for the sesh picker (sesh.sh).
# A tmux window is text, not pixels: it cannot be scaled down to fit, only cropped. `sesh preview`
# shows the top-left of the ACTIVE PANE only. This rebuilds the WHOLE current window of the
# session (every pane at its own position, borders drawn between them) and shows its centre,
# cut to the preview's exact size (fzf exports FZF_PREVIEW_LINES / FZF_PREVIEW_COLUMNS).
# Rows that are not a live tmux session (zoxide dirs, config sessions, fd results) go to sesh.
#
# Usage: sesh-preview.sh "<row as sesh list -i prints it>"

row="$1"
name="${row#* }" # drop the icon column; a bare path (ctrl-f rows) has no space and stays whole

if ! tmux has-session -t "=$name" 2>/dev/null; then
  exec sesh preview "$row"
fi

read -r W H < <(tmux display -p -t "$name" '#{window_width} #{window_height}')

# One stream: a header per pane, its captured lines (with colours), then an end marker.
{
  tmux list-panes -t "$name" -F '#{pane_left} #{pane_top} #{pane_width} #{pane_height} #{pane_id}' |
    sort -n | while read -r left top width height id; do
      echo "@@PANE@@ $left $top $width $height"
      tmux capture-pane -ep -t "$id"
      echo "@@END@@"
    done
} | awk -v W="$W" -v H="$H" -v rows="${FZF_PREVIEW_LINES:-$H}" -v cols="${FZF_PREVIEW_COLUMNS:-$W}" '
# Copy the visible cells [start, start+w) of s, keeping every SGR escape (zero width) and
# padding with spaces to exactly w cells, so panes line up column for column.
function fit(s, start, w,   out, i, j, n, c, L) {
  out = ""; n = 0; i = 1; L = length(s)
  while (i <= L && n < start + w) {
    c = substr(s, i, 1)
    if (c == "\033") {
      j = i; while (j <= L && substr(s, j, 1) !~ /[A-Za-z]/) j++
      out = out substr(s, i, j - i + 1); i = j + 1; continue
    }
    if (n >= start) out = out c
    n++; i++
  }
  while (n < start + w) { if (n >= start) out = out " "; n++ }
  return out "\033[0m"
}
function rep(c, k,   s) { s = ""; while (k-- > 0) s = s c; return s }

/^@@PANE@@ / { np++; L[np] = $2; T[np] = $3; Wd[np] = $4; Ht[np] = $5; cur = np; ln = 0; next }
/^@@END@@$/  { cur = 0; next }
cur          { line[cur, ln++] = $0; next }

END {
  for (y = 0; y < H; y++) {
    x = 0; out = ""
    for (p = 1; p <= np; p++) {          # panes come sorted by left edge
      if (L[p] < x) continue             # these columns are already drawn for this row
      covers = (y >= T[p] && y < T[p] + Ht[p])
      if (covers)                              seg = fit(line[p, y - T[p]], 0, Wd[p])
      else if (y == T[p] - 1 || y == T[p] + Ht[p]) seg = rep("─", Wd[p])
      else continue
      if (L[p] > x) out = out rep(covers ? "│" : "┼", L[p] - x)   # the vertical border column
      out = out seg; x = L[p] + Wd[p]
    }
    win[y] = out
  }
  # Centre-crop to the preview window.
  ys = (H > rows) ? int((H - rows) / 2) : 0
  xs = (W > cols) ? int((W - cols) / 2) : 0
  for (y = ys; y < ys + rows && y < H; y++) print fit(win[y], xs, cols)
}'
