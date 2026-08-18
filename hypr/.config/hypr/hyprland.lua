-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Own every keybinding, like the old hyprland.conf did by sourcing only
-- default/hypr/bindings/media.conf. Omarchy's media keys are pulled back in at
-- the top of hypr/bindings.lua; everything else is defined there by hand.
omarchy_default_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.envs")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.apps")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")
