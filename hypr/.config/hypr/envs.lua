-- Extra env variables.
-- Note: relaunch Hyprland after changing envs (Omarchy menu -> System -> Relaunch).
hl.env("EDITOR", "nvim")

-- Input method (fcitx5) -- enable together with the autostart entry in hypr/autostart.lua.
-- hl.env("GTK_IM_MODULE", "fcitx")
-- hl.env("QT_IM_MODULE", "fcitx")
-- hl.env("XMODIFIERS", "@im=fcitx")
-- hl.env("INPUT_METHOD", "fcitx")
-- hl.env("SDL_IM_MODULE", "fcitx")

-- Run Proton games on Wine's native Wayland driver instead of XWayland, so they
-- fullscreen on the monitor Hyprland gives them. Opt a game out with the Steam
-- launch option: PROTON_ENABLE_WAYLAND=0 %command%
hl.env("PROTON_ENABLE_WAYLAND", "1")
