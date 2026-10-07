-- bindings-shared.lua — Joshua's Hyprland keys that are MUSCLE MEMORY, not hardware.
-- Included from every Omarchy box's ~/.config/hypr/bindings.lua (install.sh adds the line):
--   dofile(os.getenv("HOME") .. "/projects/terminalConfig/hypr/bindings-shared.lua")
-- `hl` and `o` are Omarchy's globals, in scope when this runs. Hardware/app-specific binds
-- (lid switch, Chrome/Thunderbird pins) stay in the machine's own bindings.lua.
-- Apply live: hyprctl reload. List: omarchy menu keybindings --print.

local home = os.getenv("HOME")

-- Close window = SUPER+SHIFT+W; nothing on SUPER+W (2026-09-23: the o→w home-row-mod roll fired
-- Super+W and closed the focused window mid-typing). Omawrite loses SUPER+SHIFT+W; app menu has it.
hl.unbind("SUPER + W")
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Close window", hl.dsp.window.close())

-- Emoji picker on SUPER+CTRL+RETURN (Mac Cmd+Ctrl+Space muscle memory), replacing Omarchy's Herdr
-- launcher there; Herdr stays in the app launcher. SUPER+CTRL+SPACE keeps Omarchy's background switcher.
hl.unbind("SUPER + CTRL + RETURN")
o.bind("SUPER + CTRL + RETURN", "Emojis", "omarchy-shell shell toggle omarchy.emojis")

-- Mac-style screenshots (2026-09-28): CTRL+SHIFT+4 = smart picker (region / window), CTRL+SHIFT+5 =
-- full screen, PRINT = smart. Saved to ~/Pictures/screenshots + clipboard. The editor wrapper
-- (scripts/bin/screenshot-edit: Tensaku, re-copies on save) is used only where that repo exists.
local editor = home .. "/projects/scripts/bin/screenshot-edit"
local function screenshot(mode)
  local cmd = "env OMARCHY_SCREENSHOT_DIR=" .. home .. "/Pictures/screenshots omarchy-capture-screenshot " .. mode
  local f = io.open(editor, "r")
  if f then f:close(); cmd = cmd .. " --editor=" .. editor end
  return cmd
end
o.bind("CTRL + SHIFT + 4", "Screenshot (smart: region / window)", screenshot("smart"))
o.bind("CTRL + SHIFT + 5", "Screenshot (full screen)", screenshot("fullscreen"))
hl.unbind("PRINT")
o.bind("PRINT", "Screenshot", screenshot("smart"))
