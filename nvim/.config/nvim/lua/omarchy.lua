-- Follow the active Omarchy theme.
--
-- The colours come from the theme's colors.toml (lua/omarchy_palette.lua), so
-- nvim matches the rest of the desktop. Which syntax roles get those colours
-- is the style, picked here. Omarchy's own neovim.lua is a LazyVim spec and
-- isn't used.

local M = {}

-- Omarchy 4 ("quattro") moved this out of ~/.config into XDG state.
local STATE = vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")
local CURRENT = STATE .. "/omarchy/current"
local THEME_NAME = CURRENT .. "/theme.name"

-- Which syntax roles get colour:
--   "alabaster"  comments, strings, constants and definitions
--   "y9nika"     only declarations coloured, keywords muted below text
--   "quiet"      dim comments, green strings, nothing else
-- :OmarchyStyle switches it for the session.
M.style = "quiet"
M.STYLES = { "quiet", "alabaster", "y9nika" }

--- Name of the active Omarchy theme, e.g. "vantablack". nil if unknown.
function M.theme_name()
	local ok, lines = pcall(vim.fn.readfile, THEME_NAME)
	if not ok or not lines or not lines[1] then
		return nil
	end
	return vim.trim(lines[1])
end

--- Apply the colorscheme for the active Omarchy theme in the current style.
function M.apply()
	local ok, err = pcall(vim.cmd.colorscheme, "omarchy-" .. M.style)
	if not ok then
		vim.notify("omarchy: " .. err, vim.log.levels.WARN)
	end
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

	-- :OmarchyStyle y9nika picks one; with no argument it cycles through them.
	vim.api.nvim_create_user_command("OmarchyStyle", function(opts)
		local style = opts.args
		if style == "" then
			for i, name in ipairs(M.STYLES) do
				if name == M.style then
					style = M.STYLES[i % #M.STYLES + 1]
				end
			end
		elseif not vim.tbl_contains(M.STYLES, style) then
			vim.notify("omarchy: unknown style " .. style, vim.log.levels.ERROR)
			return
		end
		M.style = style
		M.apply()
		vim.notify("omarchy: " .. vim.g.colors_name)
	end, {
		nargs = "?",
		complete = function()
			return M.STYLES
		end,
		desc = "Switch the syntax style of the Omarchy colorscheme",
	})
end

return M
