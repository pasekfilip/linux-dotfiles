-- `:colorscheme omarchy-gruber` -- the generated Omarchy colorscheme with
-- Jonathan Blow (naysayer) style syntax: bright bold keywords, loud comments.
-- See lua/omarchy_palette.lua.
--
-- Erroring out rather than returning quietly is what lets lua/omarchy.lua
-- notice this failed and fall back to a colorscheme plugin.
if not require("omarchy_palette").load("gruber") then
	error("omarchy-gruber: no usable colors.toml for the active theme")
end
