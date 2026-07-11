# Changelog

All notable changes to terminalConfig (tmux + sesh) are documented here.

---

## 2026-07-07 - Removed `prefix F` (/fresh handoff cycle retired)

**What changed:**
- Deleted the `bind F` keybind + its comment block from `tmux/tmux.conf`. It drove `~/scripts/bin/freshnext.sh` for the `/fresh` clear+resume cycle.
- Also live-`unbind`'d `F` from the running tmux server (`tmux unbind-key F`) — `source-file` / `prefix R` re-sources the conf but does **not** drop binds deleted from the file, so a reload alone left it live.

**Why:**
- The entire `/fresh` session-handoff system was retired 2026-07-07 (sessions are now TODO-driven). `freshnext.sh` was graveyarded, so the bind pointed at a dead script. See global changelog + `graveyard/fresh-retire-2026-07/`.

**Files modified:**
- `tmux/tmux.conf` - removed `bind F` block

---

## 2026-06-20 - prefix + F now switches to the target project's sesh session

**What changed:**
- `bind F` updated to pass the triggering client to the driver:
  `run-shell -b "FRESHNEXT_CLIENT='#{client_name}' ~/scripts/bin/freshnext.sh '#{pane_id}'"`.
- `freshnext.sh` v2 (in `scripts`) now reads `~/.claude/fresh-next.state` and switches to the handoff's **target project sesh** + resumes in its `Claude` window, instead of clearing+resuming the current pane. `#{pane_id}` is now just the no-state fallback.

**Why:**
- `FRESHNEXT_CLIENT` is required because `switch-client` from a detached `run-shell -b` has no reliable "current" client — passing `#{client_name}` makes the switch land on the pane that pressed the key.

**Files modified:**
- `tmux/tmux.conf` — `bind F` (client passing) + refreshed comment

**Technical notes:**
- Binding unchanged in spirit (still `prefix F`, still detached `-b`); behavior upgrade lives in `freshnext.sh`. Verified live 2026-06-20.

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
