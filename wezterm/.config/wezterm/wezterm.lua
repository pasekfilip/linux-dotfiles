local wezterm = require("wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- local current_theme = dofile("/home/filip/.config/omarchy/current/theme/wezterm_colors.lua")

config.enable_wayland = true
config.front_end = "WebGpu"
config.max_fps = 144
config.term = "xterm-256color"
config.default_cursor_style = "SteadyBlock"
config.window_background_opacity = 0.98
config.color_scheme = "nord"
config.font = wezterm.font("CaskaydiaMono Nerd Font")
config.font_size = 18
config.window_padding = {
	left = 14,
	right = 14,
	top = 14,
	bottom = 0,
}

config.adjust_window_size_when_changing_font_size = false
config.disable_default_key_bindings = true

-- tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
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

resurrect.state_manager.periodic_save()

config.keys = {
	{
		key = "b",
		mods = "SHIFT | CTRL",
		action = wezterm.action_callback(function(win, pane)
			resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			resurrect.window_state.save_window_action()
		end),
	},
	{
		key = "r",
		mods = "SHIFT | CTRL",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = string.match(id, "(.+)%..+$") -- remove file extention
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.state_manager.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.state_manager.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.state_manager.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end)
		end),
	},
	{
		key = "f",
		mods = "SHIFT|CTRL",
		action = wezterm.action.Search("CurrentSelectionOrEmptyString"),
	},
	{
		key = "u",
		mods = "SHIFT | CTRL",
		action = wezterm.action.CopyMode("ClearPattern"),
	},
	-- {
	--     key = 'p',
	--     mods = 'CTRL',
	--     action = wezterm.action.CopyMode 'PriorMatch'
	--
	-- },
	-- {
	--     key = 'n',
	--     mods = 'CTRL',
	--     action = wezterm.action.CopyMode 'NextMatch'
	--
	-- },
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
	-- {
	-- 	key = "m",
	-- 	mods = "CTRL|SHIFT",
	-- 	action = wezterm.action.ShowLauncher,
	-- },
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
}

local current_layout_number_row = { "1", "2", "3", "4", "5" }
for i, v in ipairs(current_layout_number_row) do
	table.insert(config.keys, {
		mods = "CTRL",
		key = v,
		action = wezterm.action.ActivateTab(i - 1),
	})
end

-- --tmux restore
-- wezterm.on("save-indicator", function(window, _)
-- 	local saved_icon = " " .. "\u{eb4b}" .. "  ";
--
-- 	window:set_left_status(wezterm.format {
-- 		{ Text = saved_icon },
-- 	})
--
-- 	wezterm.sleep_ms(1500)
-- 	window:set_left_status("")
-- end)
--
return config
