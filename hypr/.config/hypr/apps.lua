-- App-specific window rules.
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- PureRef reference boards float small and centered.
o.window("PureRef", { float = true })
o.window({ class = "PureRef", title = "PureRef" }, { center = true, size = { 400, 400 } })

-- Python turtle windows open on the second monitor.
o.window("Tk", { monitor = "1" })
