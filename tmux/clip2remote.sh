#!/usr/bin/env bash
# clip2remote.sh <pane_id> <pane_pid> — prefix+v in tmux.conf (Joshua, 2026-10-15).
#
# Image paste into Claude over ssh. The clipboard lives HERE; a Claude on the far side of an ssh pane can
# only read ITS OWN clipboard, so it says "No image found. You're SSH'd; try scp?". This does the scp for you:
#   1. find the ssh the pane is running (walk the pane's process tree; no ssh = local pane, plain Ctrl+V)
#   2. read the image off the local clipboard (wl-paste)
#   3. stream it to ~/.cache/clip/clip-<time>.png on that host over a second ssh (same -p/-i/-J/-o as the pane's)
#   4. bracketed-paste the remote path into the pane, which Claude attaches like a dragged file
# Never fails silently: every stop path says why in the tmux status line.
set -u
PANE=${1:?pane id}; PANE_PID=${2:?pane pid}
say() { tmux display-message -d 4000 "clip2remote: $*"; }

# --- 1. the ssh in this pane ---------------------------------------------------------------------
descend() { local p; for p in $(pgrep -P "$1" 2>/dev/null); do echo "$p"; descend "$p"; done; }
SSH_PID=""
for p in $PANE_PID $(descend "$PANE_PID"); do
    [ "$(ps -o comm= -p "$p" 2>/dev/null)" = ssh ] && { SSH_PID=$p; break; }
done
if [ -z "$SSH_PID" ]; then   # not an ssh pane: hand Claude the ordinary Ctrl+V, so prefix+v is harmless everywhere
    tmux send-keys -t "$PANE" C-v
    exit 0
fi

# ssh options that take a value; keep only the ones that change WHERE/AS WHOM we connect.
mapfile -d '' ARGV < "/proc/$SSH_PID/cmdline"
KEEP=(); HOST=""; i=1
while [ $i -lt ${#ARGV[@]} ]; do
    a=${ARGV[$i]}
    case "$a" in
        -[bcDEeIiJLlmOopQRSWwFB])        # option with a separate value
            v=${ARGV[$((i+1))]:-}
            case "$a" in -p|-i|-l|-J|-F|-o|-S) KEEP+=("$a" "$v");; esac
            i=$((i+2)); continue;;
        -[pilJFoS]?*) KEEP+=("$a");;     # value glued on, e.g. -p2222
        -*) ;;                           # plain flag (-t, -A, -4 ...): not needed for a one-shot upload
        *) HOST=$a; break;;              # first non-option = host; everything after is the remote command
    esac
    i=$((i+1))
done
[ -n "$HOST" ] || { say "found ssh (pid $SSH_PID) but no host in its arguments"; exit 1; }

# --- 2. the image on the local clipboard ---------------------------------------------------------
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ -S "/run/user/$(id -u)/wayland-1" ]; then export WAYLAND_DISPLAY=wayland-1; fi
command -v wl-paste >/dev/null 2>&1 || { say "wl-paste not installed here"; exit 1; }
wl-paste --list-types 2>/dev/null | grep -qx 'image/png' || { say "no image on the clipboard (take a screenshot first)"; exit 1; }
TMP=$(mktemp "${TMPDIR:-/tmp}/clip2remote.XXXXXX") || exit 1
trap 'rm -f "$TMP"' EXIT
wl-paste -t image/png > "$TMP" 2>/dev/null
[ -s "$TMP" ] || { say "clipboard image read back empty"; exit 1; }

# --- 3. ship it ----------------------------------------------------------------------------------
NAME="clip-$(date +%Y%m%d-%H%M%S).png"
REMOTE=$(ssh -o BatchMode=yes -o ConnectTimeout=8 "${KEEP[@]}" "$HOST" \
    "umask 077; mkdir -p \"\$HOME/.cache/clip\" && find \"\$HOME/.cache/clip\" -name 'clip-*.png' -mtime +7 -delete 2>/dev/null; cat > \"\$HOME/.cache/clip/$NAME\" && echo \"\$HOME/.cache/clip/$NAME\"" \
    < "$TMP" 2>/dev/null | tail -1)
[ -n "$REMOTE" ] || { say "upload to $HOST failed (needs key-based ssh from this machine)"; exit 1; }

# --- 4. paste the path into the pane (bracketed, so Claude treats it as a dropped file) ----------
tmux set-buffer -b clip2remote "$REMOTE "
tmux paste-buffer -p -d -b clip2remote -t "$PANE"
say "sent image to $HOST:$REMOTE"
