-- Keep only your personal input overrides here. Settings below replace
-- Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    -- Custom layout file takes the place of kb_layout/kb_variant/kb_options.
    kb_file = "~/.config/xkb/custom.xkb",
    repeat_delay = 200,
    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    -- Turn off mouse acceleration (default: adaptive).
    accel_profile = "flat",
    force_no_accel = true,
  },
})
