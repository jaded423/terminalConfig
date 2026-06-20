# Changelog

All notable changes to terminalConfig (tmux + sesh) are documented here.

---

## 2026-06-19 - tmux: prefix + F drives the /fresh handoff cycle

**What changed:**
- Added `bind F run-shell -b "~/scripts/bin/freshnext.sh '#{pane_id}'"` (after the vim pane-selection binds).
- `prefix + F` (capital, under the `C-Space` prefix) clears + resumes the active Claude Code pane: sends `/clear` then `/fresh resume` via `freshnext.sh`. Runs detached (`-b`) so the script's settle-delay doesn't block the tmux server.

**Why:**
- One-keystroke handoff cycle for the global `/fresh` command — close a session, press `prefix F`, land in a fresh memory-loaded session.

**Files modified:**
- `tmux/tmux.conf` — new `bind F` keybind

**Technical notes:**
- No collision: `prefix f` (lowercase) stays tmux's default find-window; `prefix F` (Shift+f) is the new bind.
- The driver lives in `~/projects/scripts/bin/freshnext.sh` (see that repo's changelog).
