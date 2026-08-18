-- Bridge between the current Omarchy theme and wezterm.
--
-- Every Omarchy theme ships a colors.toml, so reading that palette means every
-- theme works with no per-theme wezterm file. It also guarantees wezterm
-- matches alacritty/btop/the shell exactly, since they all read the same
-- palette -- the ANSI mapping below is the one from Omarchy's own
-- default/themed/alacritty.toml.tpl.
--
-- Omarchy 4 ("quattro") moved two things:
--   * state from ~/.config/omarchy/current to ~/.local/state/omarchy/current
--   * colors.toml from color0..color15 to semantic names (red, bright_red, ...)

local wezterm = require("wezterm")

local M = {}

local HOME = os.getenv("HOME")
local STATE = os.getenv("XDG_STATE_HOME") or (HOME .. "/.local/state")
local CURRENT = STATE .. "/omarchy/current"
local COLORS_TOML = CURRENT .. "/theme/colors.toml"
local THEME_NAME = CURRENT .. "/theme.name"

-- Used when Omarchy isn't installed or the palette can't be read, so a broken
-- theme dir degrades to readable colors instead of a wezterm config error.
-- Keyed by the same semantic names colors.toml uses.
local FALLBACK = {
	background = "#011628",
	foreground = "#cbe0f0",
	bright_foreground = "#cbe0f0",
	lighter_background = "#143652",
	selection = "#275378",
	muted = "#414868",

	red = "#f7768e",
	green = "#9ece6a",
	yellow = "#e0af68",
	blue = "#7aa2f7",
	magenta = "#bb9af7",
	cyan = "#7dcfff",

	bright_red = "#ff899d",
	bright_green = "#9fe044",
	bright_yellow = "#faba4a",
	bright_blue = "#8db0ff",
	bright_magenta = "#c7a9ff",
	bright_cyan = "#a4daff",
}

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local contents = f:read("*a")
	f:close()
	return contents
end

-- colors.toml is a flat `key = "#rrggbb"` list, so a full TOML parser would be
-- overkill. Anything that isn't a quoted hex value is ignored (which also skips
-- the `mode = "dark"` line).
local function parse_palette(contents)
	local palette = {}
	for key, value in contents:gmatch('([%w_]+)%s*=%s*"(#%x+)"') do
		palette[key] = value
	end
	return palette
end

--- Name of the active Omarchy theme, e.g. "gruvbox". nil if unknown.
function M.theme_name()
	local contents = read_file(THEME_NAME)
	return contents and contents:match("^%s*(.-)%s*$")
end

--- The active theme's palette as a wezterm colors table.
function M.colors()
	local contents = read_file(COLORS_TOML)
	local palette = contents and parse_palette(contents) or {}

	local function color(key)
		return palette[key] or FALLBACK[key] or FALLBACK.foreground
	end

	return {
		foreground = color("foreground"),
		background = color("background"),

		cursor_bg = color("bright_foreground"),
		cursor_fg = color("background"),
		cursor_border = color("bright_foreground"),

		-- colors.toml has no selection_foreground; Omarchy derives it from
		-- bright_foreground, same as the alacritty template does.
		selection_fg = color("bright_foreground"),
		selection_bg = color("selection"),

		-- ANSI 0-7 then 8-15. Note black is the theme background and white is
		-- the theme foreground, which is how every other Omarchy-themed app
		-- renders them.
		ansi = {
			color("background"),
			color("red"),
			color("green"),
			color("yellow"),
			color("blue"),
			color("magenta"),
			color("cyan"),
			color("foreground"),
		},
		brights = {
			color("muted"),
			color("bright_red"),
			color("bright_green"),
			color("bright_yellow"),
			color("bright_blue"),
			color("bright_magenta"),
			color("bright_cyan"),
			color("bright_foreground"),
		},

		-- Without this the retro tab bar keeps wezterm's built-in colors and
		-- stops matching the rest of the window on a theme switch.
		tab_bar = {
			background = color("background"),
			active_tab = {
				bg_color = color("background"),
				fg_color = color("foreground"),
			},
			inactive_tab = {
				bg_color = color("background"),
				fg_color = color("muted"),
			},
			inactive_tab_hover = {
				bg_color = color("lighter_background"),
				fg_color = color("foreground"),
			},
			new_tab = {
				bg_color = color("background"),
				fg_color = color("muted"),
			},
			new_tab_hover = {
				bg_color = color("lighter_background"),
				fg_color = color("foreground"),
			},
		},
	}
end

--- Reload wezterm's config when the theme changes, so open windows recolor
--- without being restarted.
function M.watch()
	-- theme.name is the reliable trigger: `omarchy theme set` rebuilds the
	-- whole theme/ directory with rm -rf + mv (which breaks an inotify watch
	-- on a file inside it) and only then rewrites theme.name in place. By the
	-- time this fires the new colors.toml is already there.
	wezterm.add_to_config_reload_watch_list(THEME_NAME)
	wezterm.add_to_config_reload_watch_list(COLORS_TOML)
end

return M
