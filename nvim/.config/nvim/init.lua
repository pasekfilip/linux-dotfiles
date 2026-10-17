-- Entry point. Everything else is picked up by nvim itself from the standard
-- runtime folders (:h 'runtimepath'), no require chain:
--   plugin/      options, keymaps, autocmds, theme -- sourced at startup
--   lua/plugins/ lazy.nvim specs, one file per concern
--   lua/         modules the above require (omarchy, task, ...)
--   after/lsp/   per-server LSP settings (:h lsp-config-merge)
--   ftplugin/    per-filetype settings
--   colors/      the generated Omarchy colorschemes

-- These two have to be set before lazy.setup() below, so they can't live in
-- plugin/ (which is sourced after this file): lazy binds every plugin's
-- `keys` with whatever mapleader is at that moment, and netrw is only skipped
-- if the flag is set before its own plugin file loads.
vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Trying a no-LSP workflow: completion from buffers and snippets only, no
-- language servers. Set to true to bring back lspconfig, Mason, the LSP
-- completion source and the server list in lualine (all read this flag).
-- Java debugging (lua/plugins/dap.lua) needs jdtls, so it needs this on.
vim.g.lsp = false

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "plugins" } }, {
	checker = {
		enabled = true,
		notify = false,
	},
})
