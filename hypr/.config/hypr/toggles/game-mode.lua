-- Slower key repeat while gaming. Loaded by require("default.hypr.toggles") at
-- the end of hypr/hyprland.lua, so it wins over hypr/input.lua.
-- Copied into ~/.local/state/omarchy/toggles/hypr/ by hypr/bin/game-mode.
hl.config({
  input = {
    repeat_rate = 25,
  },
})
