-- A colorscheme built out of the active Omarchy theme's colors.toml.
--
-- Most Omarchy themes name a real nvim colorscheme in their neovim.lua, and
-- filip/omarchy.lua maps those to the plugins in filip/plugins/theme.lua. A
-- few (last-horizon, lupine, ristretto's siblings...) ship no neovim.lua at
-- all, so there is no upstream colorscheme to follow and they used to land on
-- the tokyonight fallback -- which has nothing to do with the colours the rest
-- of the desktop is showing. Every theme does ship colors.toml, so for those
-- this generates a colorscheme from it instead.
--
-- Reached through colors/omarchy.lua so `:colorscheme omarchy` works and the
-- ColorScheme event fires (lualine's "auto" theme rebuilds on it).

local M = {}

-- Omarchy 4 ("quattro") moved this out of ~/.config into XDG state.
local STATE = vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")
M.COLORS_TOML = STATE .. "/omarchy/current/theme/colors.toml"

-- Colours every theme defines; without them there is nothing to build on.
local REQUIRED = { "background", "foreground", "red", "green", "yellow", "blue", "cyan", "magenta" }

local HEX = "^#%x%x%x%x%x%x$"

--- Every `key = "value"` in colors.toml, as a flat table. Empty if unreadable.
function M.colors()
	local out = {}
	local ok, lines = pcall(vim.fn.readfile, M.COLORS_TOML)
	if not ok or not lines then
		return out
	end
	for _, line in ipairs(lines) do
		local key, value = line:match('^%s*([%w_]+)%s*=%s*"([^"]*)"')
		if key and out[key] == nil then
			out[key] = value
		end
	end
	return out
end

local function channels(hex)
	return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

local function clamp(n)
	return math.min(255, math.max(0, math.floor(n + 0.5)))
end

--- `amount` of `top` laid over `bottom`, both "#rrggbb".
local function blend(top, bottom, amount)
	local r1, g1, b1 = channels(top)
	local r2, g2, b2 = channels(bottom)
	return string.format(
		"#%02x%02x%02x",
		clamp(r1 * amount + r2 * (1 - amount)),
		clamp(g1 * amount + g2 * (1 - amount)),
		clamp(b1 * amount + b2 * (1 - amount))
	)
end

-- Contrast floor for syntax colours, in WCAG ratio against the background.
-- Below this, code stops being readable at a normal font size.
local MIN_CONTRAST = 4.0

local function relative_luminance(hex)
	local parts = { channels(hex) }
	local out = 0
	for i, weight in ipairs({ 0.2126, 0.7152, 0.0722 }) do
		local v = parts[i] / 255
		v = v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4
		out = out + weight * v
	end
	return out
end

local function contrast(a, b)
	local la, lb = relative_luminance(a), relative_luminance(b)
	if la < lb then
		la, lb = lb, la
	end
	return (la + 0.05) / (lb + 0.05)
end

--- `color` nudged toward `toward` until it is legible on `bg`, keeping its hue.
--- Omarchy palettes are picked for terminal accents, not for syntax: some of
--- them are far too dim to read as code. last-horizon's yellow is a near-black
--- plum, which would make every type declaration vanish into the background.
local function readable(color, bg, toward)
	for _ = 1, 20 do
		if contrast(color, bg) >= MIN_CONTRAST then
			break
		end
		color = blend(toward, color, 0.08)
	end
	return color
end

local function mode_of(colors)
	-- Omarchy 4 states this outright, so prefer it over guessing.
	if colors.mode == "light" or colors.mode == "dark" then
		return colors.mode
	end
	local bg = colors.background
	if not bg or not bg:match(HEX) then
		return nil
	end
	local r, g, b = channels(bg)
	return (0.299 * r + 0.587 * g + 0.114 * b) > 127 and "light" or "dark"
end

--- "light" or "dark" for the active theme. nil if colors.toml can't be read.
function M.mode()
	return mode_of(M.colors())
end

--- The theme's palette plus the shades a colorscheme needs that Omarchy does
--- not name. nil when colors.toml is missing or too incomplete to use.
function M.palette()
	local c = M.colors()
	for _, key in ipairs(REQUIRED) do
		if not c[key] or not c[key]:match(HEX) then
			return nil
		end
	end

	--- colors.toml value for `key`, or `fallback` when it is absent.
	local function hex(key, fallback)
		local v = c[key]
		return (v and v:match(HEX)) and v or fallback
	end

	local p = { mode = mode_of(c) or "dark" }

	p.bg = c.background
	p.fg = c.foreground
	p.bg_dark = hex("dark_background", blend("#000000", p.bg, 0.25))
	p.bg_darker = hex("darker_background", blend("#000000", p.bg, 0.4))
	p.fg_dark = hex("dark_foreground", blend(p.fg, p.bg, 0.6))
	p.fg_light = hex("light_foreground", p.fg)
	p.fg_bright = hex("bright_foreground", p.fg)
	p.accent = hex("accent", c.blue)
	p.muted = hex("muted", blend(p.fg, p.bg, 0.45))
	p.selection = hex("selection", blend(p.fg, p.bg, 0.2))

	for _, name in ipairs({ "red", "green", "yellow", "blue", "cyan", "magenta" }) do
		p[name] = c[name]
		p["bright_" .. name] = hex("bright_" .. name, c[name])
	end
	-- Three themes leave these two out; last-horizon is one of them.
	p.orange = hex("orange", blend(p.red, p.yellow, 0.6))
	p.brown = hex("brown", blend(p.orange, p.bg, 0.7))

	for _, name in ipairs({ "red", "green", "yellow", "blue", "cyan", "magenta", "orange", "brown", "accent" }) do
		p[name] = readable(p[name], p.bg, p.fg_bright)
	end

	-- lighter_background is Omarchy's panel surface, but last-horizon sets it
	-- equal to background, which would make the cursor line invisible. Derive
	-- the raised surfaces from the foreground instead so they always show.
	p.raised = blend(p.fg, p.bg, 0.06)
	p.raised_more = blend(p.fg, p.bg, 0.12)
	p.border = blend(p.muted, p.bg, 0.7)

	return p
end

local function highlights(p)
	return {
		-- Editor
		Normal = { fg = p.fg, bg = p.bg },
		NormalNC = { link = "Normal" },
		NormalFloat = { fg = p.fg, bg = p.bg_dark },
		FloatBorder = { fg = p.border, bg = p.bg_dark },
		FloatTitle = { fg = p.accent, bg = p.bg_dark, bold = true },
		ColorColumn = { bg = p.raised },
		Conceal = { fg = p.muted },
		Cursor = { fg = p.bg, bg = p.fg },
		lCursor = { link = "Cursor" },
		CursorIM = { link = "Cursor" },
		CursorLine = { bg = p.raised },
		CursorColumn = { bg = p.raised },
		CursorLineNr = { fg = p.accent, bold = true },
		LineNr = { fg = p.muted },
		LineNrAbove = { link = "LineNr" },
		LineNrBelow = { link = "LineNr" },
		SignColumn = { fg = p.muted, bg = p.bg },
		FoldColumn = { fg = p.muted, bg = p.bg },
		-- Folds read as a dimmed line rather than a highlighted band.
		Folded = { fg = p.muted, bg = "NONE" },
		MatchParen = { fg = p.orange, bold = true },
		ModeMsg = { fg = p.fg_bright, bold = true },
		MoreMsg = { fg = p.accent },
		MsgArea = { fg = p.fg },
		NonText = { fg = blend(p.muted, p.bg, 0.6) },
		Whitespace = { fg = blend(p.muted, p.bg, 0.5) },
		EndOfBuffer = { fg = p.bg },
		Pmenu = { fg = p.fg, bg = p.bg_dark },
		PmenuSel = { bg = p.raised_more, bold = true },
		PmenuSbar = { bg = p.bg_darker },
		PmenuThumb = { bg = p.muted },
		PmenuKind = { fg = p.cyan, bg = p.bg_dark },
		PmenuExtra = { fg = p.muted, bg = p.bg_dark },
		Question = { fg = p.accent },
		QuickFixLine = { bg = p.selection, bold = true },
		Search = { fg = p.fg_bright, bg = blend(p.accent, p.bg, 0.3) },
		IncSearch = { fg = p.bg, bg = p.orange },
		CurSearch = { link = "IncSearch" },
		Substitute = { fg = p.bg, bg = p.red },
		SpecialKey = { fg = p.muted },
		SpellBad = { undercurl = true, sp = p.red },
		SpellCap = { undercurl = true, sp = p.yellow },
		SpellLocal = { undercurl = true, sp = p.cyan },
		SpellRare = { undercurl = true, sp = p.magenta },
		StatusLine = { fg = p.fg_light, bg = p.bg_dark },
		StatusLineNC = { fg = p.muted, bg = p.bg_dark },
		TabLine = { fg = p.muted, bg = p.bg_dark },
		TabLineFill = { bg = p.bg_darker },
		TabLineSel = { fg = p.accent, bg = p.bg },
		Title = { fg = p.accent, bold = true },
		VertSplit = { fg = p.border },
		WinSeparator = { fg = p.border },
		Visual = { bg = p.selection },
		VisualNOS = { link = "Visual" },
		WarningMsg = { fg = p.orange },
		ErrorMsg = { fg = p.red },
		WildMenu = { link = "PmenuSel" },
		Directory = { fg = p.accent },
		WinBar = { fg = p.fg_light, bg = p.bg },
		WinBarNC = { fg = p.muted, bg = p.bg },

		-- Syntax
		Comment = { fg = p.muted, italic = true },
		Constant = { fg = p.orange },
		String = { fg = p.green },
		Character = { fg = p.green },
		Number = { fg = p.orange },
		Boolean = { fg = p.orange },
		Float = { fg = p.orange },
		Identifier = { fg = p.fg },
		Function = { fg = p.blue },
		Statement = { fg = p.magenta },
		Conditional = { fg = p.magenta },
		Repeat = { fg = p.magenta },
		Label = { fg = p.magenta },
		Operator = { fg = p.cyan },
		Keyword = { fg = p.magenta },
		Exception = { fg = p.magenta },
		PreProc = { fg = p.cyan },
		Include = { fg = p.cyan },
		Define = { fg = p.cyan },
		Macro = { fg = p.cyan },
		PreCondit = { fg = p.cyan },
		Type = { fg = p.yellow },
		StorageClass = { fg = p.yellow },
		Structure = { fg = p.yellow },
		Typedef = { fg = p.yellow },
		Special = { fg = p.cyan },
		SpecialChar = { fg = p.orange },
		Tag = { fg = p.red },
		Delimiter = { fg = p.fg_dark },
		SpecialComment = { fg = p.muted, bold = true, italic = true },
		Debug = { fg = p.red },
		Underlined = { underline = true },
		Bold = { bold = true },
		Italic = { italic = true },
		Ignore = { fg = p.muted },
		Error = { fg = p.red },
		Todo = { fg = p.bg, bg = p.yellow, bold = true },

		-- Diffs
		DiffAdd = { bg = blend(p.green, p.bg, 0.18) },
		DiffChange = { bg = blend(p.blue, p.bg, 0.14) },
		DiffDelete = { bg = blend(p.red, p.bg, 0.18) },
		DiffText = { bg = blend(p.blue, p.bg, 0.32) },
		-- Makes the '-' filler lines read as clean background.
		DiffFiller = { fg = p.bg_dark, bg = p.bg_dark },
		diffAdded = { fg = p.green },
		diffRemoved = { fg = p.red },
		diffChanged = { fg = p.blue },
		diffFile = { fg = p.accent },
		diffLine = { fg = p.muted },
		diffIndexLine = { fg = p.magenta },
		Added = { fg = p.green },
		Changed = { fg = p.blue },
		Removed = { fg = p.red },

		-- Diagnostics. todo-comments takes its colours from these too.
		DiagnosticError = { fg = p.red },
		DiagnosticWarn = { fg = p.orange },
		DiagnosticInfo = { fg = p.blue },
		DiagnosticHint = { fg = p.cyan },
		DiagnosticOk = { fg = p.green },
		DiagnosticVirtualTextError = { fg = p.red, bg = blend(p.red, p.bg, 0.1) },
		DiagnosticVirtualTextWarn = { fg = p.orange, bg = blend(p.orange, p.bg, 0.1) },
		DiagnosticVirtualTextInfo = { fg = p.blue, bg = blend(p.blue, p.bg, 0.1) },
		DiagnosticVirtualTextHint = { fg = p.cyan, bg = blend(p.cyan, p.bg, 0.1) },
		DiagnosticUnderlineError = { undercurl = true, sp = p.red },
		DiagnosticUnderlineWarn = { undercurl = true, sp = p.orange },
		DiagnosticUnderlineInfo = { undercurl = true, sp = p.blue },
		DiagnosticUnderlineHint = { undercurl = true, sp = p.cyan },
		DiagnosticUnnecessary = { fg = p.muted },
		DiagnosticDeprecated = { fg = p.muted, strikethrough = true },

		-- LSP
		LspReferenceText = { bg = p.raised_more },
		LspReferenceRead = { link = "LspReferenceText" },
		LspReferenceWrite = { bg = p.raised_more, underline = true },
		LspInlayHint = { fg = p.muted, bg = p.raised, italic = true },
		LspSignatureActiveParameter = { fg = p.orange, bold = true },
		LspCodeLens = { fg = p.muted, italic = true },

		-- Tree-sitter
		["@variable"] = { fg = p.fg },
		["@variable.builtin"] = { fg = p.red },
		["@variable.parameter"] = { fg = p.yellow },
		["@variable.member"] = { fg = p.cyan },
		["@constant"] = { fg = p.orange },
		["@constant.builtin"] = { fg = p.orange },
		["@constant.macro"] = { fg = p.cyan },
		["@module"] = { fg = p.yellow },
		["@label"] = { fg = p.magenta },
		["@string"] = { fg = p.green },
		["@string.escape"] = { fg = p.magenta },
		["@string.special"] = { fg = p.cyan },
		["@string.special.url"] = { fg = p.accent, underline = true },
		["@character"] = { fg = p.green },
		["@number"] = { fg = p.orange },
		["@boolean"] = { fg = p.orange },
		["@function"] = { fg = p.blue },
		["@function.builtin"] = { fg = p.cyan },
		["@function.macro"] = { fg = p.cyan },
		["@constructor"] = { fg = p.yellow },
		["@operator"] = { fg = p.cyan },
		["@keyword"] = { fg = p.magenta },
		["@keyword.return"] = { fg = p.magenta, italic = true },
		["@keyword.import"] = { fg = p.cyan },
		["@keyword.exception"] = { fg = p.magenta },
		["@punctuation.delimiter"] = { fg = p.fg_dark },
		["@punctuation.bracket"] = { fg = p.fg_dark },
		["@punctuation.special"] = { fg = p.cyan },
		["@comment"] = { link = "Comment" },
		["@comment.todo"] = { fg = p.bg, bg = p.cyan, bold = true },
		["@comment.note"] = { fg = p.bg, bg = p.blue, bold = true },
		["@comment.warning"] = { fg = p.bg, bg = p.orange, bold = true },
		["@comment.error"] = { fg = p.bg, bg = p.red, bold = true },
		["@tag"] = { fg = p.red },
		["@tag.attribute"] = { fg = p.orange },
		["@tag.delimiter"] = { fg = p.fg_dark },
		["@type"] = { fg = p.yellow },
		["@type.builtin"] = { fg = blend(p.yellow, p.bg, 0.8) },
		["@property"] = { fg = p.cyan },
		["@attribute"] = { fg = p.cyan },
		["@markup.heading"] = { fg = p.accent, bold = true },
		["@markup.strong"] = { bold = true },
		["@markup.italic"] = { italic = true },
		["@markup.strikethrough"] = { strikethrough = true },
		["@markup.underline"] = { underline = true },
		["@markup.link"] = { fg = p.accent },
		["@markup.link.url"] = { fg = p.accent, underline = true },
		["@markup.raw"] = { fg = p.green },
		["@markup.list"] = { fg = p.red },
		["@markup.quote"] = { fg = p.muted, italic = true },
		["@diff.plus"] = { fg = p.green },
		["@diff.minus"] = { fg = p.red },
		["@diff.delta"] = { fg = p.blue },
		["@lsp.type.namespace"] = { link = "@module" },
		["@lsp.type.parameter"] = { link = "@variable.parameter" },
		["@lsp.type.property"] = { link = "@property" },
		["@lsp.type.enumMember"] = { fg = p.orange },
		["@lsp.type.enum"] = { link = "@type" },
		["@lsp.type.interface"] = { link = "@type" },
		["@lsp.type.class"] = { link = "@type" },
		["@lsp.type.decorator"] = { link = "@attribute" },
		["@lsp.type.macro"] = { link = "@function.macro" },

		-- gitsigns
		GitSignsAdd = { fg = p.green },
		GitSignsChange = { fg = p.blue },
		GitSignsDelete = { fg = p.red },
		GitSignsAddInline = { bg = blend(p.green, p.bg, 0.3) },
		GitSignsChangeInline = { bg = blend(p.blue, p.bg, 0.3) },
		GitSignsDeleteInline = { bg = blend(p.red, p.bg, 0.3) },
		GitSignsCurrentLineBlame = { fg = p.muted, italic = true },

		-- indent-blankline
		IblIndent = { fg = blend(p.muted, p.bg, 0.4) },
		IblScope = { fg = blend(p.accent, p.bg, 0.7) },

		-- nvim-cmp
		CmpItemAbbr = { fg = p.fg_light },
		CmpItemAbbrDeprecated = { fg = p.muted, strikethrough = true },
		CmpItemAbbrMatch = { fg = p.accent, bold = true },
		CmpItemAbbrMatchFuzzy = { link = "CmpItemAbbrMatch" },
		CmpItemKind = { fg = p.cyan },
		CmpItemMenu = { fg = p.muted },

		-- fzf-lua
		FzfLuaNormal = { fg = p.fg, bg = p.bg_dark },
		FzfLuaBorder = { fg = p.border, bg = p.bg_dark },
		FzfLuaTitle = { fg = p.accent, bold = true },
		FzfLuaCursorLine = { bg = p.raised_more, bold = true },
		FzfLuaHeaderText = { fg = p.red },
		FzfLuaHeaderBind = { fg = p.orange },
		FzfLuaPathColNr = { fg = p.cyan },
		FzfLuaPathLineNr = { fg = p.green },
		FzfLuaFzfMatch = { fg = p.accent, bold = true },
		FzfLuaFzfPrompt = { fg = p.magenta },
		FzfLuaFzfPointer = { fg = p.red },
	}
end

--- Apply the generated colorscheme. false when colors.toml can't be used, so
--- the caller can fall back to a real colorscheme plugin.
function M.load()
	local p = M.palette()
	if not p then
		return false
	end

	-- Before the clear: setting 'background' re-sources the colorscheme, and
	-- doing that halfway through would undo what we are about to set.
	if vim.o.background ~= p.mode then
		vim.o.background = p.mode
	end

	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.o.termguicolors = true
	vim.g.colors_name = "omarchy"

	for group, opts in pairs(highlights(p)) do
		vim.api.nvim_set_hl(0, group, opts)
	end

	local terminal = {
		p.bg_dark,
		p.red,
		p.green,
		p.yellow,
		p.blue,
		p.magenta,
		p.cyan,
		p.fg_light,
		p.muted,
		p.bright_red,
		p.bright_green,
		p.bright_yellow,
		p.bright_blue,
		p.bright_magenta,
		p.bright_cyan,
		p.fg_bright,
	}
	for i, color in ipairs(terminal) do
		vim.g["terminal_color_" .. (i - 1)] = color
	end

	return true
end

return M
