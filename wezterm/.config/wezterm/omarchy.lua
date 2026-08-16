-- Bridge between the current Omarchy theme and wezterm.
--
-- Every Omarchy theme ships a colors.toml (omarchy generates one from
-- alacritty.toml if the theme author didn't write one), so reading that
-- palette means every theme works with no per-theme wezterm file.
-- It also guarantees wezterm matches alacritty/btop/waybar exactly, since
-- they all read the same palette.

local wezterm = require("wezterm")

local M = {}

local HOME = os.getenv("HOME")
local CURRENT = HOME .. "/.config/omarchy/current"
local COLORS_TOML = CURRENT .. "/theme/colors.toml"
local THEME_NAME = CURRENT .. "/theme.name"

-- Used when Omarchy isn't installed or the palette can't be read, so a broken
-- theme dir degrades to readable colors instead of a wezterm config error.
local FALLBACK = {
	foreground = "#cbe0f0",
	background = "#011628",
	cursor = "#cbe0f0",
	selection_foreground = "#011628",
	selection_background = "#275378",
	color0 = "#15161e",
	color1 = "#f7768e",
	color2 = "#9ece6a",
	color3 = "#e0af68",
	color4 = "#7aa2f7",
	color5 = "#bb9af7",
	color6 = "#7dcfff",
	color7 = "#a9b1d6",
	color8 = "#414868",
	color9 = "#ff899d",
	color10 = "#9fe044",
	color11 = "#faba4a",
	color12 = "#8db0ff",
	color13 = "#c7a9ff",
	color14 = "#a4daff",
	color15 = "#c0caf5",
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
-- overkill. Anything that isn't a quoted hex value is ignored.
local function parse_palette(contents)
	local palette = {}
	for key, value in contents:gmatch('([%w_]+)%s*=%s*"(#%x+)"') do
		palette[key] = value
	end
	return palette
end

--- Name of the active Omarchy theme, e.g. "vantablack". nil if unknown.
function M.theme_name()
	local contents = read_file(THEME_NAME)
	return contents and contents:match("^%s*(.-)%s*$")
end

--- The active theme's palette as a wezterm colors table.
function M.colors()
	local contents = read_file(COLORS_TOML)
	local palette = contents and parse_palette(contents) or {}

	local function color(key)
		return palette[key] or FALLBACK[key]
	end

	local ansi, brights = {}, {}
	for i = 0, 7 do
		ansi[i + 1] = color("color" .. i)
		brights[i + 1] = color("color" .. (i + 8))
	end

	return {
		foreground = color("foreground"),
		background = color("background"),

		cursor_bg = color("cursor"),
		cursor_fg = color("background"),
		cursor_border = color("cursor"),

		selection_fg = color("selection_foreground"),
		selection_bg = color("selection_background"),

		ansi = ansi,
		brights = brights,

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
				fg_color = color("color8"),
			},
			inactive_tab_hover = {
				bg_color = color("color0"),
				fg_color = color("foreground"),
			},
			new_tab = {
				bg_color = color("background"),
				fg_color = color("color8"),
			},
			new_tab_hover = {
				bg_color = color("color0"),
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
