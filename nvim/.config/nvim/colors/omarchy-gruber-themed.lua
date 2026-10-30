-- `:colorscheme omarchy-gruber-themed` -- the generated Omarchy colorscheme
-- with Gruber Darker's hierarchy in the theme's hues. See
-- lua/omarchy_palette.lua.
--
-- Erroring out rather than returning quietly is what lets lua/omarchy.lua
-- notice this failed and say so.
if not require("omarchy_palette").load("gruber-themed") then
	error("omarchy-gruber-themed: no usable colors.toml for the active theme")
end
