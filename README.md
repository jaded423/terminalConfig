<div align="center">

```
████████╗███╗   ███╗██╗   ██╗██╗  ██╗     ┃     ███████╗███████╗███████╗██╗  ██╗
╚══██╔══╝████╗ ████║██║   ██║╚██╗██╔╝     ┃     ██╔════╝██╔════╝██╔════╝██║  ██║
   ██║   ██╔████╔██║██║   ██║ ╚███╔╝      ┃     ███████╗█████╗  ███████╗███████║
   ██║   ██║╚██╔╝██║██║   ██║ ██╔██╗      ┃     ╚════██║██╔══╝  ╚════██║██╔══██║
   ██║   ██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗     ┃     ███████║███████╗███████║██║  ██║
   ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝     ┃     ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
```

# 🐍 terminalConfig

**tmux · sesh · Catppuccin Mocha · prefix=`C-Space` · vim-nav · session-as-workflow**

[jadedviber.com](https://jadedviber.com) · [/now](https://jadedviber.com/now.html) · [github.com/jaded423](https://github.com/jaded423)

*One prefix. Many sessions. No mouse required.*

![tmux](https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white)
![sesh](https://img.shields.io/badge/sesh-session_manager-bd93f9?style=for-the-badge)
![Catppuccin](https://img.shields.io/badge/theme-Catppuccin_Mocha-cba6f7?style=for-the-badge)

</div>

---

```bash
$ whoami
joshua brown — vibe coder · homelab tinkerer · AI-driven dev

$ cat /workflow.md
tmux as the long-lived shell. sesh as the session router. one prefix
(C-Space, easier on Colemak-DH) drives everything. vim-tmux-navigator
makes splits and panes one keyboard surface across nvim ↔ tmux.

$ ls ~/.config/{tmux,sesh}/
tmux/tmux.conf  tmux/sesh.sh  sesh/sesh.toml  sesh/scripts/

$ uptime
catppuccin mocha · paired with nvimConfig · still vibin'
```

---

## ✨ What makes it different

- 🌌 **`C-Space` prefix** — friendlier than `C-b` on Colemak-DH home row
- 🪟 **vim-tmux-navigator** — `<C-hjkl>` crosses nvim splits AND tmux panes seamlessly. **j/k are swapped everywhere here (j = up, k = down)** — Colemak-DH puts the J cap above K; same swap in nvim, lazygit, Telescope. Pairs with smart-splits in [nvimConfig](https://github.com/jaded423/nvimConfig)
- 🧭 **sesh = session manager** — fuzzy session picker on `prefix S` (FZF-driven; opens on the session you are in). Pre-defined sessions auto-launch nvim/claude/ssh-to-host on open
- 💾 **resurrect + continuum** — sessions survive reboot. 15-min autosave
- 🖥️ **status bar at top** — battery, online indicator, time, custom session display
- 🎨 **Catppuccin Mocha** — matches the broader Dracula/cyberpunk vibe across [nvimConfig](https://github.com/jaded423/nvimConfig) + system theme
- ⌨️ **Vim copy mode** — `v` to select, `y` to yank to system clipboard via `tmux-yank`

---

## 📦 Plugin loadout

<details>
<summary><b>tmux plugins (TPM-managed)</b></summary>

| Plugin | Purpose |
|---|---|
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sane defaults |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | `<C-hjkl>` across nvim + tmux |
| [catppuccin/tmux](https://github.com/catppuccin/tmux) | Theme (Mocha flavor) |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | System clipboard copy |
| [tmux-battery](https://github.com/tmux-plugins/tmux-battery) | Battery in status bar |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save every 15 min |

</details>

<details>
<summary><b>External tools (system binaries)</b></summary>

| Tool | Purpose |
|---|---|
| [sesh](https://github.com/joshmedeski/sesh) | Smart session manager + picker |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy picker (used by sesh) |

</details>

---

## 🚀 Install

```bash
# macOS
brew install tmux sesh fzf

# Clone
git clone https://github.com/jaded423/terminalConfig.git ~/projects/terminalConfig

# Symlink tmux + sesh, write the Ghostty stub, clone TPM and install its plugins (idempotent)
~/projects/terminalConfig/install.sh
```

---

## ⌨️ Key bindings

**Prefix:** `C-Space`

### Sessions (sesh)

| Key | Action |
|---|---|
| `prefix S` | Sesh fuzzy session picker — the session you opened it from is the first row and named in the border; `C-d` closes the highlighted row |
| `prefix s` | Default tmux session picker |

### Panes

| Key | Action |
|---|---|
| `prefix h/j/k/l` | Select pane (vim-style) |
| `<C-h/j/k/l>` | Navigate across nvim ↔ tmux (vim-tmux-navigator) |
| `M-Arrow` | Select pane (no prefix) |
| `prefix v` / `b` | Vertical / horizontal split (custom in `sesh.sh`) |

### Windows

| Key | Action |
|---|---|
| `S-Left` / `S-Right` | Previous / next window |
| `M-H` / `M-L` | Previous / next window (alt-vim) |

### Copy mode (vi)

| Key | Action |
|---|---|
| `prefix [` | Enter copy mode |
| `v` | Begin selection |
| `C-v` | Toggle rectangle selection |
| `y` | Copy to system clipboard |

---

## 📁 Structure

```
~/projects/terminalConfig/
├── tmux/                        # symlinked → ~/.config/tmux
│   ├── tmux.conf                # main config
│   ├── sesh.sh                  # helper scripts (split, sesh launchers)
│   └── plugins/                 # TPM-managed (gitignored)
└── sesh/                        # symlinked → ~/.config/sesh
    ├── sesh.toml                # named-session definitions
    └── scripts/
        ├── default.sh           # default session: claude + neo (nvim)
        ├── remote.sh            # SSH multiplex: book5/omarchy/tower/ubuntu
        └── btop.sh              # system monitor session
```

---

## 🧭 Sesh sessions

Pre-defined sessions in `sesh/sesh.toml`:

| Name | What it spawns |
|---|---|
| `default` | Window 1: `claude` (Claude Code CLI). Window 2: `nvim` |
| `remote` | Multi-window SSH split: Book5, Omarchy, Tower, Ubuntu — full homelab on one prefix |
| `btop` | System monitor in a dedicated session |

Add your own in `sesh.toml`. `sesh` auto-detects git repos in `~/projects` as ephemeral sessions too.

---

## 🎨 Customization

**Prefix** — per machine, in `tmux.conf` (one tracked file, no per-host override):
```tmux
%if "#{==:#{host_short},multi-verse}"
set -g prefix C-n        # reached from inside a Pocket tmux — a prefix can't pass through itself
%else
set -g prefix C-Space    # the Pocket
%endif
```

**Change theme** — `tmux.conf`:
```tmux
set -g @catppuccin_flavor 'mocha'   # latte | frappe | macchiato | mocha
```

**Add a sesh session** — append to `sesh/sesh.toml`:
```toml
[[session]]
name = "my-stack"
startup_command = "~/.config/sesh/scripts/my-stack.sh"
```

---

## 🤖 AI-assisted, end-to-end

Like [nvimConfig](https://github.com/jaded423/nvimConfig), this config was iterated through dialogue with Claude (Anthropic). The session-as-workflow pattern (one prefix → one fuzzy picker → one session per project/task) came out of pairing with AI on how to reduce context-switching cost.

Day-to-day AI runs in a dedicated tmux pane via `claude` (Claude Code CLI) — never embedded in the editor.

---

## 🐛 Troubleshooting

```bash
# Plugins not loading
prefix + I            # capital I, inside tmux — installs from .tmux.conf

# Sesh not finding sessions
sesh list             # verify sessions defined
sesh connect <name>   # manual connect

# Resurrect not restoring
ls ~/.local/share/tmux/resurrect/    # check saved state
prefix + C-r          # manual restore
```

vim-tmux-navigator `<C-hjkl>` not crossing into nvim? → nvim side needs [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) (already in [nvimConfig](https://github.com/jaded423/nvimConfig)).

---

## 🔗 Resources

- [tmux wiki](https://github.com/tmux/tmux/wiki) · [sesh](https://github.com/joshmedeski/sesh) · [TPM](https://github.com/tmux-plugins/tpm) · [Catppuccin tmux](https://github.com/catppuccin/tmux)
- Pairs with [nvimConfig](https://github.com/jaded423/nvimConfig) — the same j/k swap, Dracula theme, full LSP/Treesitter stack

---

## 📝 License

MIT — see [LICENSE](LICENSE)

---

<div align="center">

```
$ tmux kill-server
[detached]
```

*<sub>maintained by [@jaded423](https://github.com/jaded423) · paired with [nvimConfig](https://github.com/jaded423/nvimConfig) · built end-to-end through dialogue with AI · cyberpunk-styled · monospace everything</sub>*

**[jadedviber.com](https://jadedviber.com)** · *All vibe. No grind.* 🐍

</div>
