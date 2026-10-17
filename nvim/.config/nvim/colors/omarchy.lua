-- `:colorscheme omarchy` -- generated from the active Omarchy theme's
-- colors.toml. See lua/omarchy_palette.lua.
--
-- Erroring out rather than returning quietly is what lets lua/omarchy.lua
-- notice this failed and fall back to a colorscheme plugin.
if not require("omarchy_palette").load() then
	error("omarchy: no usable colors.toml for the active theme")
end
