#!/usr/bin/env sh
# terminalConfig install: symlink tmux + sesh into ~/.config, and write the 2-line Ghostty stub
# (Ghostty has no OS conditionals — the stub picks linux.conf or mac.conf). Idempotent.
set -u
REPO="$(cd "$(dirname "$0")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$CFG"
for d in tmux sesh; do
  if [ -L "$CFG/$d" ] || [ ! -e "$CFG/$d" ]; then
    ln -sfn "$REPO/$d" "$CFG/$d" && echo "  linked ~/.config/$d"
  else
    echo "  ~/.config/$d exists and is not a symlink — left alone (move it aside, re-run)"
  fi
done
case "$(uname -s)" in Darwin) os=mac ;; *) os=linux ;; esac
G="$CFG/ghostty"; mkdir -p "$G"
if [ -f "$G/config" ] && ! grep -q 'terminalConfig/ghostty/config' "$G/config"; then
  mv "$G/config" "$G/config.pre-terminalConfig" && echo "  moved old ghostty config aside → config.pre-terminalConfig"
fi
if [ ! -f "$G/config" ]; then
  printf 'config-file = %s/ghostty/config\nconfig-file = %s/ghostty/%s.conf\n' "$REPO" "$REPO" "$os" > "$G/config"
  echo "  wrote ghostty stub ($os)"
else
  echo "  ghostty stub present"
fi
