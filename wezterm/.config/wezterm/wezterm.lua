local wezterm = require("wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Colors come from the active Omarchy theme's colors.toml; see omarchy.lua.
local omarchy = require("omarchy")
omarchy.watch()

config.enable_kitty_keyboard = true
config.enable_wayland = true
config.front_end = "WebGpu"
config.max_fps = 144
config.term = "xterm-256color"
config.default_cursor_style = "SteadyBlock"
config.window_background_opacity = 0.98
config.colors = omarchy.colors()
config.font = wezterm.font("CaskaydiaMono Nerd Font")
config.font_size = 18
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 0,
}

config.adjust_window_size_when_changing_font_size = false
config.disable_default_key_bindings = true

--tab
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

wezterm.on("window-opacity-change", function(window)
	local overrides = window:get_config_overrides() or {}

	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 1
	else
		overrides.window_background_opacity = nil
	end

	window:set_config_overrides(overrides)
end)

local act = wezterm.action
config.keys = {
	{
		key = "r",
		mods = "SUPER",
		action = act.PromptInputLine({
			description = "Enter new name for tab.",
			action = wezterm.action_callback(function(window, pane, line)
				window:active_tab():set_title(line)
			end),
		}),
	},
	{
		key = "f",
		mods = "SHIFT|CTRL",
		action = wezterm.action.Search("CurrentSelectionOrEmptyString"),
	},
	{
		mods = "CTRL | SHIFT",
		key = "d",
		action = wezterm.action.ShowDebugOverlay,
	},
	{
		mods = "CTRL | SHIFT",
		key = "g",
		action = wezterm.action.EmitEvent("window-opacity-change"),
	},
	{
		mods = "CTRL",
		key = "Space",
		action = wezterm.action.SendKey({
			mods = "CTRL",
			key = "Space",
		}),
	},
	{
		mods = "CTRL",
		key = "Backspace",
		action = wezterm.action.SendKey({
			key = "w",
			mods = "CTRL",
		}),
	},
	{
		mods = "CTRL | SHIFT",
		key = "t",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		mods = "CTRL | SHIFT",
		key = "x",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		mods = "CTRL | SHIFT",
		key = "w",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		mods = "CTRL | SHIFT",
		key = "p",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		mods = "CTRL | SHIFT",
		key = "n",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		mods = "CTRL | SHIFT",
		key = "v",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
	{
		mods = "CTRL | SHIFT",
		key = "c",
		action = wezterm.action.CopyTo("ClipboardAndPrimarySelection"),
	},
	{
		mods = "CTRL | SHIFT",
		key = "s",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "CTRL | SHIFT",
		key = "-",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "CTRL",
		key = "=",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		mods = "CTRL",
		key = "-",
		action = wezterm.action.DecreaseFontSize,
	},
	{
		mods = "CTRL | SHIFT",
		key = "<",
		action = wezterm.action.MoveTabRelative(-1),
	},
	{
		mods = "CTRL | SHIFT",
		key = ">",
		action = wezterm.action.MoveTabRelative(1),
	},
	{

		mods = "CTRL | SHIFT",
		key = "h",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		mods = "CTRL | SHIFT",
		key = "j",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		mods = "CTRL | SHIFT",
		key = "k",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		mods = "CTRL | SHIFT",
		key = "l",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		mods = "CTRL | SHIFT",
		key = "LeftArrow",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		mods = "CTRL | SHIFT",
		key = "RightArrow",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		mods = "CTRL | SHIFT",
		key = "DownArrow",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		mods = "CTRL | SHIFT",
		key = "UpArrow",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
}

local current_layout_number_row = { "1", "2", "3", "4", "5" }
for i, v in ipairs(current_layout_number_row) do
	table.insert(config.keys, {
		mods = "CTRL",
		key = v,
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config
