-- A colorscheme built out of the active Omarchy theme's colors.toml, so nvim
-- shows the same colours as the rest of the desktop. Every theme ships one.
--
-- Reached through colors/omarchy-<style>.lua so `:colorscheme` works and the
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

--- Everything but syntax: editor UI, diffs, diagnostics and plugins. The
--- styles below supply the syntax groups.
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

--- Alabaster-style syntax (tonsky/sublime-scheme-alabaster). Only four roles
--- get a colour -- comments, strings, constants and definitions -- and
--- everything else is plain foreground, so what stands out is where things
--- are declared and what literal data the code holds. Keywords, types, calls
--- and operators are readable from syntax alone.
---
--- This is the complete set of syntax groups: `highlight clear` leaves nvim's
--- own defaults on anything not set here, and those are full colour.
local function alabaster(p)
	local comment = { fg = p.yellow }
	-- Themes pick green as a terminal accent, and some are neon. Pulling it
	-- toward grey takes the edge off those while barely moving soft ones.
	local string = { fg = readable(blend(p.green, p.fg_dark, 0.65), p.bg, p.fg_bright) }
	local constant = { fg = p.magenta }
	local definition = { fg = p.blue }
	local plain = { fg = p.fg }
	-- Not p.fg_dark: themes ship that as their comment grey, and on some
	-- (everforest, white) it is barely above the background. A step down
	-- from the text itself keeps punctuation quieter but always legible.
	local punct = { fg = readable(blend(p.fg, p.bg, 0.65), p.bg, p.fg) }

	return {
		-- Syntax (non-Tree-sitter filetypes)
		Comment = comment,
		SpecialComment = comment,
		String = string,
		Character = string,
		SpecialChar = string,
		Constant = constant,
		Number = constant,
		Boolean = constant,
		Float = constant,
		Function = definition,
		Identifier = plain,
		Statement = plain,
		Conditional = plain,
		Repeat = plain,
		Label = plain,
		Operator = plain,
		Keyword = plain,
		Exception = plain,
		PreProc = plain,
		Include = plain,
		Define = plain,
		Macro = plain,
		PreCondit = plain,
		Type = plain,
		StorageClass = plain,
		Structure = plain,
		Typedef = plain,
		Special = plain,
		Tag = plain,
		Delimiter = punct,
		Underlined = { underline = true },
		Bold = { bold = true },
		Italic = { italic = true },
		Ignore = { fg = p.muted },
		Error = { fg = p.red },
		Todo = { fg = p.bg, bg = p.yellow, bold = true },

		-- Tree-sitter. Captures fall back along their dots (@function.call ->
		-- @function), so the use-site captures must be set explicitly or calls
		-- would pick up the definition colour.
		["@comment"] = comment,
		["@comment.todo"] = { fg = p.bg, bg = p.cyan, bold = true },
		["@comment.note"] = { fg = p.bg, bg = p.blue, bold = true },
		["@comment.warning"] = { fg = p.bg, bg = p.orange, bold = true },
		["@comment.error"] = { fg = p.bg, bg = p.red, bold = true },
		["@string"] = string,
		["@string.escape"] = string,
		["@string.special"] = string,
		["@string.special.url"] = { fg = string.fg, underline = true },
		["@character"] = string,
		["@constant"] = constant,
		["@constant.builtin"] = constant,
		["@number"] = constant,
		["@boolean"] = constant,
		["@function"] = definition,
		["@function.method"] = definition,
		["@function.macro"] = definition,
		["@constant.macro"] = definition,
		["@type.definition"] = definition,
		["@function.call"] = plain,
		["@function.method.call"] = plain,
		["@function.builtin"] = plain,
		["@constructor"] = plain,
		["@variable"] = plain,
		["@variable.builtin"] = plain,
		["@variable.parameter"] = plain,
		["@variable.member"] = plain,
		["@property"] = plain,
		["@module"] = plain,
		["@label"] = plain,
		["@operator"] = plain,
		["@keyword"] = plain,
		-- The one keyword that stands out: an exit is easy to miss in a long
		-- function. Comment yellow, as y9nika does with its marker.
		["@keyword.return"] = comment,
		["@keyword.import"] = plain,
		["@keyword.exception"] = plain,
		["@type"] = plain,
		["@type.builtin"] = plain,
		["@attribute"] = plain,
		["@tag"] = plain,
		["@tag.attribute"] = plain,
		["@tag.delimiter"] = punct,
		["@punctuation.delimiter"] = punct,
		["@punctuation.bracket"] = punct,
		["@punctuation.special"] = punct,
		-- Our own captures, from after/queries/<lang>/highlights.scm: names
		-- at the point they are introduced. Uses stay @variable (plain).
		-- Locals are plain (pure Alabaster). To try them coloured, use a hue
		-- of their own (y9nika-style, e.g. p.orange), not a tint of fg: a
		-- tinted fg is too close to fg to read reliably.
		["@alabaster.definition"] = definition,
		["@alabaster.local"] = plain,

		-- LSP semantic tokens outrank Tree-sitter, and nvim links
		-- @lsp.type.function/method/macro to the definition captures for every
		-- use. Clearing them lets Tree-sitter decide; the declaration modifier
		-- puts the definition colour back where it belongs.
		["@lsp.type.function"] = {},
		["@lsp.type.method"] = {},
		["@lsp.type.macro"] = {},
		["@lsp.type.enumMember"] = constant,
		["@lsp.typemod.function.declaration"] = definition,
		["@lsp.typemod.method.declaration"] = definition,
		["@lsp.typemod.macro.declaration"] = definition,
		["@lsp.typemod.class.declaration"] = definition,
		["@lsp.typemod.struct.declaration"] = definition,
		["@lsp.typemod.enum.declaration"] = definition,
		["@lsp.typemod.type.declaration"] = definition,
		-- clangd marks inactive #if branches as comment tokens; dim them
		-- instead of lighting them up like real comments. Scoped to C/C++:
		-- lua_ls sends every real comment as a comment token too, and those
		-- would flash from the comment colour to muted once the LSP attaches.
		["@lsp.type.comment"] = {},
		["@lsp.type.comment.c"] = { fg = p.muted },
		["@lsp.type.comment.cpp"] = { fg = p.muted },

		-- Markdown: structure from weight, not hue. Headings bold foreground,
		-- list markers like punctuation; inline code keeps the string colour.
		["@markup.heading"] = { fg = p.fg_bright, bold = true },
		["@markup.list"] = punct,
		["@markup.link"] = { fg = p.fg, underline = true },
		["@markup.link.url"] = { fg = p.muted, underline = true },
		["@markup.raw"] = string,
		["@markup.strong"] = { bold = true },
		["@markup.italic"] = { italic = true },
		["@markup.strikethrough"] = { strikethrough = true },
		["@markup.underline"] = { underline = true },
		["@markup.quote"] = { fg = p.muted, italic = true },
		["@diff.plus"] = { fg = p.green },
		["@diff.minus"] = { fg = p.red },
		["@diff.delta"] = { fg = p.blue },

		-- oil links these to Comment to mean "dim", but Comment is the loud
		-- yellow here, so hidden files ended up standing out the most.
		OilHidden = { fg = p.muted },
		OilEmpty = { fg = p.muted },
		OilLinkTarget = { fg = p.muted },
		OilTrashSourcePath = { fg = p.muted },
	}
end

--- y9nika-style syntax (y9san9/y9nika.nvim), laid over alabaster(). Only
--- declarations are coloured: definitions (top-level names) in primary blue,
--- locals in secondary green, comments in the yellow marker. Literals share
--- the locals' green -- six base colours, not eight. Keywords, operators and
--- punctuation are muted *below* the text, since they are the most obvious
--- part of any program; `return` alone gets the marker, as an exit. No bold
--- or italics anywhere: scanning is easier when weight never changes.
local function y9nika(p)
	local base = { fg = p.fg }
	local declaration = { fg = p.blue }
	-- Same softening as alabaster()'s strings, for the same neon greens.
	local variable = { fg = readable(blend(p.green, p.fg_dark, 0.65), p.bg, p.fg_bright) }
	local marker = { fg = p.yellow }
	local muted = { fg = readable(blend(p.fg, p.bg, 0.65), p.bg, p.fg) }

	return vim.tbl_extend("force", alabaster(p), {
		-- Syntax (non-Tree-sitter filetypes)
		Comment = marker,
		SpecialComment = marker,
		String = variable,
		Character = variable,
		SpecialChar = muted,
		Number = variable,
		Float = variable,
		Boolean = variable,
		Constant = base,
		Function = declaration,
		Statement = muted,
		Conditional = muted,
		Repeat = muted,
		Label = muted,
		Keyword = muted,
		Exception = muted,
		StorageClass = muted,
		Structure = muted,
		Typedef = muted,
		Operator = muted,
		Delimiter = muted,

		-- Tree-sitter
		["@comment"] = marker,
		["@string"] = variable,
		["@string.escape"] = muted,
		["@string.special"] = variable,
		["@string.special.url"] = { fg = variable.fg, underline = true },
		["@character"] = variable,
		["@number"] = variable,
		["@boolean"] = variable,
		["@constant"] = base,
		["@constant.builtin"] = base,
		["@keyword"] = muted,
		["@keyword.import"] = muted,
		["@keyword.exception"] = muted,
		["@keyword.return"] = marker,
		["@operator"] = muted,
		["@punctuation.delimiter"] = muted,
		["@punctuation.bracket"] = muted,
		["@punctuation.special"] = muted,
		["@markup.heading"] = declaration,
		["@markup.raw"] = variable,
		["@alabaster.definition"] = declaration,
		["@alabaster.local"] = variable,

		["@lsp.type.enumMember"] = base,
	})
end

--- Nearly monochrome (after nvim's built-in `quiet`, as james-orcales/big_bang
--- uses it), laid over alabaster(). Comments are dimmed into the background
--- and everything else -- strings, keywords, return, constants, numbers,
--- definitions, punctuation -- is plain text, so whatever turns out to be
--- missed while reading is what earns a colour back.
local function quiet(p)
	-- Not p.muted: some themes' is near the background. Like big_bang's #888
	-- on #DFE0DC text: about half way down, never below the contrast floor.
	local comment = { fg = readable(blend(p.fg, p.bg, 0.55), p.bg, p.fg) }
	local plain = { fg = p.fg }
	-- Kept as its own role so giving strings a colour back is one line.
	local string = plain

	return vim.tbl_extend("force", alabaster(p), {
		-- Syntax (non-Tree-sitter filetypes)
		Comment = comment,
		SpecialComment = comment,
		Todo = comment,
		String = string,
		Character = string,
		SpecialChar = string,
		Constant = plain,
		Number = plain,
		Boolean = plain,
		Float = plain,
		Function = plain,
		Delimiter = plain,

		-- Tree-sitter
		["@comment"] = comment,
		["@comment.todo"] = comment,
		["@comment.note"] = comment,
		["@comment.warning"] = comment,
		["@comment.error"] = comment,
		["@string"] = string,
		["@string.escape"] = string,
		["@string.special"] = string,
		["@string.special.url"] = { fg = string.fg, underline = true },
		["@character"] = string,
		["@constant"] = plain,
		["@constant.builtin"] = plain,
		["@number"] = plain,
		["@boolean"] = plain,
		["@function"] = plain,
		["@function.method"] = plain,
		["@function.macro"] = plain,
		["@constant.macro"] = plain,
		["@type.definition"] = plain,
		["@keyword.return"] = plain,
		["@tag.delimiter"] = plain,
		["@punctuation.delimiter"] = plain,
		["@punctuation.bracket"] = plain,
		["@punctuation.special"] = plain,
		["@markup.list"] = plain,
		["@markup.raw"] = string,
		["@alabaster.definition"] = plain,

		["@lsp.type.enumMember"] = plain,
		["@lsp.typemod.function.declaration"] = plain,
		["@lsp.typemod.method.declaration"] = plain,
		["@lsp.typemod.macro.declaration"] = plain,
		["@lsp.typemod.class.declaration"] = plain,
		["@lsp.typemod.struct.declaration"] = plain,
		["@lsp.typemod.enum.declaration"] = plain,
		["@lsp.typemod.type.declaration"] = plain,
	})
end

local STYLES = { alabaster = alabaster, y9nika = y9nika, quiet = quiet }

--- Apply the generated colorscheme in `style` (a key of STYLES),
--- whose function's syntax groups are laid over highlights(). false when
--- colors.toml can't be used.
function M.load(style)
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
	vim.g.colors_name = "omarchy-" .. style

	local groups = vim.tbl_extend("force", highlights(p), STYLES[style](p))

	for group, opts in pairs(groups) do
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
