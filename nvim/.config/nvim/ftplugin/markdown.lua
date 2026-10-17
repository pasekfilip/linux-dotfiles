-- Prose, not code: wrap long lines at word boundaries, and keep wrapped list
-- items indented under their bullet. The gj/gk j/k maps in plugin/keymaps.lua
-- then move by screen line through wrapped paragraphs.
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
