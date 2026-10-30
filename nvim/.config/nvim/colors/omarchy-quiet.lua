-- `:colorscheme omarchy-quiet` -- the generated Omarchy colorscheme with
-- nearly monochrome syntax: dim comments, gold strings, coloured definitions.
-- See lua/omarchy_palette.lua.
--
-- Erroring out rather than returning quietly is what lets lua/omarchy.lua
-- notice this failed and say so.
if not require("omarchy_palette").load("quiet") then
	error("omarchy-quiet: no usable colors.toml for the active theme")
end
