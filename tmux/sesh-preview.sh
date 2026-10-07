#!/usr/bin/env bash
# fzf preview for the sesh picker (sesh.sh).
# A tmux window is text, not pixels: it cannot be scaled down to fit, only cropped. `sesh preview`
# shows the top-left of the ACTIVE PANE only. This rebuilds the WHOLE current window of the
# session: the LAYOUT is scaled to the preview (fzf exports FZF_PREVIEW_LINES / _COLUMNS), and
# each pane's region is filled with that pane's BOTTOM-LEFT content — the prompt end of a shell,
# the line-number side of an editor — with borders drawn between the panes.
# Rows that are not a live tmux session (zoxide dirs, config sessions, fd results) go to sesh.
#
# Usage: sesh-preview.sh "<row as sesh list -i prints it>"

row="$1"
name="${row#* }" # drop the icon column; a bare path (ctrl-f rows) has no space and stays whole

if ! tmux has-session -t "=$name" 2>/dev/null; then
  exec sesh preview "$row"
fi

read -r W H < <(tmux display -p -t "=$name:" '#{window_width} #{window_height}')

# One stream: a header per pane, its captured lines (with colours), then an end marker.
{
  tmux list-panes -t "=$name:" -F '#{pane_left} #{pane_top} #{pane_width} #{pane_height} #{pane_id}' |
    sort -n | while read -r left top width height id; do
      echo "@@PANE@@ $left $top $width $height"
      tmux capture-pane -ep -t "$id"
      echo "@@END@@"
    done
} | awk -v W="$W" -v H="$H" -v rows="${FZF_PREVIEW_LINES:-$H}" -v cols="${FZF_PREVIEW_COLUMNS:-$W}" '
# Copy the first w visible cells of s, keeping every CSI escape (zero width) and padding with
# spaces to exactly w cells, so pane regions line up column for column.
function fit(s, w,   out, i, j, n, c, L) {
  out = ""; n = 0; i = 1; L = length(s)
  while (i <= L && n < w) {
    c = substr(s, i, 1)
    if (c == "\033") {
      if (substr(s, i + 1, 1) == "[") {        # CSI: ESC [ params… final byte (@ to ~)
        j = i + 2; while (j <= L && substr(s, j, 1) !~ /[@-~]/) j++
      } else j = i + 1                         # any other two-byte escape
      out = out substr(s, i, j - i + 1); i = j + 1; continue
    }
    out = out c; n++; i++
  }
  while (n < w) { out = out " "; n++ }
  return out "\033[0m"
}
function rep(c, k,   s) { s = ""; while (k-- > 0) s = s c; return s }
function sx(c) { return int(c * cols / W) }   # scale a column / row of the real window
function sy(r) { return int(r * rows / H) }

/^@@PANE@@ / { np++; L[np] = $2; T[np] = $3; Wd[np] = $4; Ht[np] = $5; cur = np; ln = 0; next }
/^@@END@@$/  { cur = 0; next }
cur {
  # OSC sequences (hyperlinks, titles) are invisible AND terminate elsewhere; a cut one would
  # swallow the rest of the preview. Drop them whole.
  gsub(/\033\][^\007\033]*(\007|\033\\)/, "")
  t = $0; gsub(/\033\[[^@-~]*[@-~]/, "", t)
  if (t ~ /[^ ]/) last[cur] = ln           # last line with something on it
  line[cur, ln++] = $0; next
}

END {
  # Scaled region per pane. A pane that is not flush with the window edge gives up one column
  # (row) on its right (bottom) for the border, which is why the span is measured to Wd+1.
  for (p = 1; p <= np; p++) {
    l2[p] = sx(L[p]); r = (L[p] + Wd[p] < W) ? sx(L[p] + Wd[p] + 1) - 1 : cols; w2[p] = r - l2[p]
    t2[p] = sy(T[p]); b = (T[p] + Ht[p] < H) ? sy(T[p] + Ht[p] + 1) - 1 : rows; h2[p] = b - t2[p]
  }
  for (y = 0; y < rows; y++) {
    x = 0; out = ""
    for (p = 1; p <= np; p++) {          # panes come sorted by left edge
      if (l2[p] < x || w2[p] < 1) continue   # columns already drawn, or a sliver too thin to show
      covers = (y >= t2[p] && y < t2[p] + h2[p])
      if (covers) {
        # Anchor to the bottom of the pane's CONTENT (a fresh pane may draw at the top and leave
        # the rest empty): show the h2 lines ending at its last non-blank line.
        end = (p in last) ? last[p] + 1 : Ht[p]
        if (end < h2[p]) end = h2[p]
        if (end > Ht[p]) end = Ht[p]
        src = end - h2[p] + (y - t2[p])
        if (src < 0) src = 0
        seg = fit(line[p, src], w2[p])
      } else if ((T[p] > 0 && y == t2[p] - 1) || (T[p] + Ht[p] < H && y == t2[p] + h2[p])) {
        seg = rep("─", w2[p])
      } else continue
      if (l2[p] > x) out = out rep(covers ? "│" : "┼", l2[p] - x)   # the vertical border column
      out = out seg; x = l2[p] + w2[p]
    }
    print out
  }
}'
