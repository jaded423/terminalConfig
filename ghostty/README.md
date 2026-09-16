# ghostty/

Ghostty has no per-OS conditionals, so the repo holds three files and each machine keeps a 2-line stub:

| File | Job |
|---|---|
| `config` | shared: cursor, clipboard, Shift+Enter CSI-u, scroll |
| `linux.conf` | Omarchy theme include → `dark.conf` (black @ 0.85, must be a separate include to load after the theme), JetBrainsMono 11, Hyprland fixes |
| `dark.conf` | the black-glass override, Linux only |
| `mac.conf` | Phala Green Dark, MesloLGS 14 (the retired dev Mac's look) |

Stub `~/.config/ghostty/config` (written by `unibrain/install-all.sh`, or by hand):
```
config-file = ~/projects/terminalConfig/ghostty/config
config-file = ~/projects/terminalConfig/ghostty/linux.conf   # or mac.conf
```
On macOS Ghostty also reads `~/Library/Application Support/com.mitchellh.ghostty/config`; leave that empty or make it the same stub.
History: Mac config lived only in Application Support (outside every repo) until 2026-09-15; the Pocket's config + `dark.conf` were merged into these.
