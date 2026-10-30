-- `:colorscheme omarchy-gruber` -- Tsoding's Gruber Darker
-- (rexim/gruber-darker-theme) in its own fixed colours, without the bold.
-- See lua/omarchy_palette.lua.
--
-- Erroring out rather than returning quietly is what lets lua/omarchy.lua
-- notice this failed and say so.
if not require("omarchy_palette").load("gruber") then
	error("omarchy-gruber: could not build the Gruber palette")
end
