-- `:colorscheme omarchy-y9nika` -- the generated Omarchy colorscheme with
-- y9nika-style syntax: only declarations coloured, keywords muted.
-- See lua/omarchy_palette.lua.
--
-- Erroring out rather than returning quietly is what lets lua/omarchy.lua
-- notice this failed and say so.
if not require("omarchy_palette").load("y9nika") then
	error("omarchy-y9nika: no usable colors.toml for the active theme")
end
