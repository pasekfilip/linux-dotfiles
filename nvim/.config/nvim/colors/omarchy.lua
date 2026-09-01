-- `:colorscheme omarchy` -- generated from the active Omarchy theme's
-- colors.toml. See lua/filip/omarchy_palette.lua.
--
-- Erroring out rather than returning quietly is what lets filip/omarchy.lua
-- notice this failed and fall back to a colorscheme plugin.
if not require("filip.omarchy_palette").load() then
	error("omarchy: no usable colors.toml for the active theme")
end
