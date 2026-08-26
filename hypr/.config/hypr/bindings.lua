-- Every keybinding lives here: hypr/hyprland.lua sets
-- omarchy_default_bindings = false, so nothing but the media keys below comes
-- from Omarchy. See current bindings with: omarchy menu keybindings --print

-- Keep Omarchy's volume / brightness / media / touchpad keys.
require("default.hypr.bindings.media")

-- Applications
-- Omarchy's own terminal-tmux runs `bash -c "tmux attach || tmux new -s Work"`.
-- Detaching (prefix d) makes `tmux attach` exit 0, bash has nothing left to run,
-- and the window closes with it -- the session survives, but the tab vanishing
-- on every detach is jarring. Two changes:
--   `new -A -s Work`  attach if it exists, create if not, in one command, so no
--                     exit status decides anything.
--   `exec bash`       after detaching you land in a plain shell in the same
--                     window: re-attach, or close it yourself.
o.bind("ALT + RETURN", "Terminal", "omarchy-launch-terminal bash -c 'tmux new -A -s Work; exec bash'")
o.bind("ALT + E", "File manager", { launch = "nautilus --new-window" })
o.bind("ALT + B", "Browser", "omarchy-launch-browser")
o.bind("ALT + M", "Music", { launch = "spotify" })

o.bind("ALT + T", "Activity", "uwsm-app -- ghostty --class=org.omarchy.btop --font-size=12 -e btop --preset 1")
o.bind("ALT + SHIFT + W", "Toggle weather", "omarchy-notification-weather")

o.bind("ALT + Y", "YouTube", { webapp = "https://youtube.com/" })

-- Windows
o.bind("ALT + W", "Close active window", hl.dsp.window.close())
o.bind("ALT + P", "Pseudo window", hl.dsp.window.pseudo())
o.bind("ALT + V", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
o.bind("ALT + F", "Force full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Move focus with ALT + hjkl
o.bind("ALT + H", "Move focus left", hl.dsp.focus({ direction = "l" }))
o.bind("ALT + L", "Move focus right", hl.dsp.focus({ direction = "r" }))
o.bind("ALT + K", "Move focus up", hl.dsp.focus({ direction = "u" }))
o.bind("ALT + J", "Move focus down", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with ALT + [0-9], move windows with ALT + SHIFT + [0-9]
for workspace = 1, 10 do
	local key = "code:" .. tostring(workspace + 9)
	o.bind("ALT + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
	o.bind(
		"ALT + SHIFT + " .. key,
		"Move window to workspace " .. workspace,
		hl.dsp.window.move({ workspace = tostring(workspace) })
	)
end

o.bind("ALT + SHIFT + H", "Move window to the left", hl.dsp.window.move({ direction = "l" }))
o.bind("ALT + SHIFT + L", "Move window to the right", hl.dsp.window.move({ direction = "r" }))
o.bind("ALT + SHIFT + K", "Move window up", hl.dsp.window.move({ direction = "u" }))
o.bind("ALT + SHIFT + J", "Move window down", hl.dsp.window.move({ direction = "d" }))

o.bind("SUPER + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
o.bind("SUPER + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

o.bind("ALT + TAB", "Cycle to next window", hl.dsp.window.cycle_next())

-- Resize the active window
o.bind("ALT + LEFT", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("ALT + RIGHT", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
o.bind("ALT + SHIFT + UP", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
o.bind("ALT + SHIFT + DOWN", "Expand window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- Game mode: slow the key repeat rate down while gaming. The script owns the
-- state (hypr/toggles/game-mode.lua) so the bar indicator stays in sync.
o.bind("SUPER + S", "Toggle game mode", "~/.config/hypr/bin/game-mode")

-- Menus
o.bind("ALT + D", "Launch apps", "omarchy-menu toggle apps")
o.bind("ALT + O", "Omarchy menu", "omarchy-menu toggle")
-- o.bind("ALT , "Power menu", "omarchy-menu toggle system")
o.bind("ALT + ESCAPE", "Show key bindings", "omarchy-menu-keybindings")

-- Aesthetics
-- o.bind_toggle("ALT + SHIFT + T", "Toggle top bar", "bar")
o.bind("ALT + SHIFT + B", "Next background in theme", "omarchy-theme-bg-next")
o.bind("ALT + SHIFT + T", "Pick new theme", "omarchy-menu toggle theme")

-- Notifications (xkbcommon names the key "comma"; upper-case "COMMA" won't match)
o.bind("ALT + comma", "Dismiss last notification", "omarchy-shell notifications dismissOne")
o.bind("ALT + SHIFT + comma", "Dismiss all notifications", "omarchy-shell notifications dismissAll")
o.bind_toggle("ALT + CTRL + comma", "Toggle silencing notifications", "notification-silencing")

-- Brightness
o.bind_toggle("ALT + CTRL + N", "Toggle nightlight", "nightlight")
-- Omarchy drives external displays over DDC itself (omarchy-brightness-display-ddc)
-- and renders the shell OSD, so the old ~/.local/bin/monitor-brightness is gone.
-- Note: this acts on the focused monitor; add --monitor DP-1 to pin one.
o.bind("ALT + code:21", "Brightness up", "omarchy-brightness-display +5%", { repeating = true })
o.bind("ALT + code:20", "Brightness down", "omarchy-brightness-display 5%-", { repeating = true })

-- Screenshots
o.bind("ALT + Q", "Screenshot of region", "omarchy-capture-screenshot")
o.bind(
	"ALT + R",
	"OCR Japanese text from region",
	'grim -g "$(slurp)" /tmp/ocr.png && tesseract -l jpn /tmp/ocr.png - | tr -d "[:space:]" | wl-copy && rm /tmp/ocr.png'
)
o.bind("SUPER + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")
