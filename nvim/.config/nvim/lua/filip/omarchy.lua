-- Follow the active Omarchy theme.
--
-- Omarchy themes ship a neovim.lua, but it is a LazyVim spec that pins
-- LazyVim/LazyVim and sets opts.colorscheme on it, so it can't be consumed
-- from a plain lazy.nvim config. Instead this reads the theme name Omarchy
-- writes to <state>/omarchy/current/theme.name and maps it to a colorscheme
-- declared in filip/plugins/theme.lua.
--
-- Themes with no neovim.lua get a colorscheme generated from their palette --
-- see filip/omarchy_palette.lua.
--
-- To support another Omarchy theme: add its plugin to theme.lua (lazy = true)
-- and add a row to MAP below. `plugin` is the name lazy.nvim knows it by,
-- which is the repo basename unless the spec sets `name`.

local M = {}

local palette = require("filip.omarchy_palette")

-- Omarchy 4 ("quattro") moved this out of ~/.config into XDG state.
local STATE = vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")
local CURRENT = STATE .. "/omarchy/current"
local THEME_NAME = CURRENT .. "/theme.name"

-- For themes with no entry in MAP: a colorscheme generated from the theme's
-- own colors.toml, so nvim still shows the colours the rest of the desktop is
-- using instead of some unrelated theme's.
local GENERATED = { colorscheme = "omarchy" }

-- Last resort, for when Omarchy isn't installed at all. Two of them so a light
-- desktop doesn't land on a dark editor.
local FALLBACK = {
	dark = { plugin = "tokyonight.nvim", colorscheme = "tokyonight-night" },
	light = { plugin = "catppuccin", colorscheme = "catppuccin-latte" },
}

-- Omarchy theme name -> nvim colorscheme. Choices follow each theme's own
-- neovim.lua so nvim matches what the rest of the desktop is showing. Themes
-- that ship no neovim.lua (last-horizon, lupine, ...) are deliberately absent:
-- they have no upstream colorscheme to follow, so GENERATED handles them.
M.MAP = {
	["catppuccin"] = { plugin = "catppuccin", colorscheme = "catppuccin" },
	["catppuccin-latte"] = { plugin = "catppuccin", colorscheme = "catppuccin-latte" },
	["ethereal"] = { plugin = "ethereal.nvim", colorscheme = "ethereal" },
	["everforest"] = { plugin = "everforest-nvim", colorscheme = "everforest" },
	["flexoki-light"] = { plugin = "flexoki-neovim", colorscheme = "flexoki-light" },
	["gruvbox"] = { plugin = "gruvbox.nvim", colorscheme = "gruvbox" },
	["hackerman"] = { plugin = "hackerman.nvim", colorscheme = "hackerman" },
	["kanagawa"] = { plugin = "kanagawa.nvim", colorscheme = "kanagawa" },
	["lumon"] = { plugin = "lumon.nvim", colorscheme = "lumon" },
	["matte-black"] = { plugin = "matteblack.nvim", colorscheme = "matteblack" },
	["miasma"] = { plugin = "miasma.nvim", colorscheme = "miasma" },
	["nord"] = { plugin = "nightfox.nvim", colorscheme = "nordfox" },
	["osaka-jade"] = { plugin = "bamboo.nvim", colorscheme = "bamboo" },
	["retro-82"] = { plugin = "retro-82.nvim", colorscheme = "retro-82" },
	["ristretto"] = { plugin = "monokai-pro.nvim", colorscheme = "monokai-pro" },
	["rose-pine"] = { plugin = "rose-pine", colorscheme = "rose-pine-dawn" },
	["solitude"] = { plugin = "ashen.nvim", colorscheme = "ashen" },
	["tokyo-night"] = { plugin = "tokyonight.nvim", colorscheme = "tokyonight-night" },
	["vantablack"] = { plugin = "vantablack.nvim", colorscheme = "vantablack" },
	["white"] = { plugin = "white.nvim", colorscheme = "white" },
}

--- Name of the active Omarchy theme, e.g. "vantablack". nil if unknown.
function M.theme_name()
	local ok, lines = pcall(vim.fn.readfile, THEME_NAME)
	if not ok or not lines or not lines[1] then
		return nil
	end
	return vim.trim(lines[1])
end

--- "light" or "dark" for the active Omarchy theme. nil if it can't be read.
---
--- This has to be set before the colorscheme: gruvbox, everforest and kanagawa
--- pick their variant from vim.o.background, so going from a light Omarchy
--- theme to a dark one would otherwise leave them rendering the light variant.
function M.background()
	return palette.mode()
end

local function set_colorscheme(entry)
	-- The colorscheme plugins are all lazy = true, so only the one actually in
	-- use gets loaded. Nothing loads them for us -- lazy.nvim has no built-in
	-- load-on-colorscheme trigger -- so ask for it explicitly.
	if entry.plugin then
		pcall(function()
			require("lazy").load({ plugins = { entry.plugin } })
		end)
	end
	return pcall(vim.cmd.colorscheme, entry.colorscheme)
end

--- Apply the colorscheme matching the active Omarchy theme.
function M.apply()
	local name = M.theme_name()
	local entry = name and M.MAP[name]

	local background = M.background()
	if background then
		vim.o.background = background
	end

	if entry and set_colorscheme(entry) then
		return
	end

	if entry then
		vim.notify(
			("omarchy: colorscheme %q for theme %q failed to load"):format(entry.colorscheme, name),
			vim.log.levels.WARN
		)
	end

	if set_colorscheme(GENERATED) then
		return
	end

	set_colorscheme(FALLBACK[background or "dark"])
end

--- Re-apply when `omarchy theme set` runs, so open buffers recolor in place.
function M.watch()
	local handle = vim.uv.new_fs_event()
	if not handle then
		return
	end

	-- Watch the directory rather than theme.name itself: `omarchy theme set`
	-- rebuilds current/theme with rm -rf + mv, and a directory watch survives
	-- that where a watch on a replaced file would not.
	local pending = false
	local ok = handle:start(CURRENT, {}, function(err, filename)
		if err or filename ~= "theme.name" or pending then
			return
		end
		-- A single theme switch produces several inotify events; coalesce them
		-- so the colorscheme is applied once.
		pending = true
		vim.defer_fn(function()
			pending = false
			M.apply()
		end, 100)
	end)

	if not ok then
		handle:close()
		return
	end

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = vim.api.nvim_create_augroup("omarchy_theme_watch", { clear = true }),
		callback = function()
			pcall(function()
				handle:stop()
				handle:close()
			end)
		end,
	})
end

function M.setup()
	M.apply()
	M.watch()

	vim.api.nvim_create_user_command("OmarchyTheme", function()
		M.apply()
		vim.notify("omarchy: " .. (M.theme_name() or "unknown") .. " -> " .. vim.g.colors_name)
	end, { desc = "Re-apply the colorscheme for the current Omarchy theme" })
end

return M
