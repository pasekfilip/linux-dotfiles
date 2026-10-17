-- Follow the active Omarchy theme. See lua/omarchy.lua.
-- plugin/ is sourced after init.lua's lazy.setup(), which this needs: it
-- loads the colorscheme plugin for the active theme on demand.
require("omarchy").setup()
