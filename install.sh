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
# TPM + plugins headless (2026-10-07): a fresh machine (multi-verse) sat without the status-bar
# theme because the only install path was prefix+I inside a running tmux.
TPM="$REPO/tmux/plugins/tpm"
if [ ! -d "$TPM" ]; then
  git clone -q https://github.com/tmux-plugins/tpm "$TPM" && echo "  cloned tpm"
fi
"$TPM/bin/install_plugins" 2>&1 | grep -i "success\|fail" | sed "s/^/  /"
tmux source-file "$REPO/tmux/tmux.conf" >/dev/null 2>&1 || true

# Hyprland (Omarchy boxes only): include the shared muscle-memory binds from ~/.config/hypr/bindings.lua
HB="$HOME/.config/hypr/bindings.lua"
if [ -f "$HB" ] && ! grep -q "hypr/bindings-shared.lua" "$HB"; then
  printf '\n-- Muscle-memory keys shared by every Omarchy box (close window, emoji, screenshots):\ndofile(os.getenv("HOME") .. "/projects/terminalConfig/hypr/bindings-shared.lua")\n' >> "$HB"
  echo "  hypr: bindings-shared.lua included from ~/.config/hypr/bindings.lua (hyprctl reload to apply)"
fi
# System copy for OTHER users on this box (their home cannot read ours): root-owned, refreshed each run.
SYS=/usr/local/share/terminalConfig/hypr/bindings-shared.lua
if [ -f "$HB" ] && sudo -n true 2>/dev/null; then
  sudo install -D -m 644 "$REPO/hypr/bindings-shared.lua" "$SYS" && echo "  hypr: system copy refreshed at $SYS (secondary users include this one)"
fi
