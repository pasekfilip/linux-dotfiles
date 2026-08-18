-- Extra autostart processes.
o.exec_on_start("xrandr --output DP-1 --primary")
-- o.exec_on_start(o.launch("hyprsunset"))

-- Omarchy's own clipboard plugin (SUPER + V) keeps history now, so the old
-- cliphist watcher is no longer needed. Re-enable if you still want cliphist.
-- o.exec_on_start("wl-paste --watch cliphist store")

-- o.exec_on_start("fcitx5 -d")
