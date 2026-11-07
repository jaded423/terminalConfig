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
-- full screen, PRINT = smart. Saved to ~/Pictures/screenshots + clipboard. Annotation is omasnap's
-- own editor (preview toast → Edit). 2026-11-07: Omarchy 4.5 made `--editor` take only
-- window|overlay and dropped Tensaku, so the old `--editor=<script path>` made omasnap exit
-- ("--editor takes window or overlay") and every screenshot key silently did nothing.
local function screenshot(mode)
  return "env OMARCHY_SCREENSHOT_DIR=" .. home .. "/Pictures/screenshots omarchy-capture-screenshot " .. mode
end
o.bind("CTRL + SHIFT + 4", "Screenshot (smart: region / window)", screenshot("smart"))
o.bind("CTRL + SHIFT + 5", "Screenshot (full screen)", screenshot("fullscreen"))
hl.unbind("PRINT")
o.bind("PRINT", "Screenshot", screenshot("smart"))
