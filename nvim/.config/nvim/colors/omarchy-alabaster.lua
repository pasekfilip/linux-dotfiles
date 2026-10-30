-- `:colorscheme omarchy-alabaster` -- the generated Omarchy colorscheme with
-- Alabaster-style syntax: only comments, strings, constants and definitions
-- are coloured. See lua/omarchy_palette.lua.
--
-- Erroring out rather than returning quietly is what lets lua/omarchy.lua
-- notice this failed and say so.
if not require("omarchy_palette").load("alabaster") then
	error("omarchy-alabaster: no usable colors.toml for the active theme")
end
