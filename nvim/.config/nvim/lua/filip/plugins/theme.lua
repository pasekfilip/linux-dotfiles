-- Colorschemes for the Omarchy themes. Nothing here sets the colorscheme:
-- filip/omarchy.lua reads the active Omarchy theme and loads exactly one of
-- these. They are all lazy so the other ones cost nothing at startup.
--
-- Adding a theme: add the plugin here and a row to M.MAP in filip/omarchy.lua.

return {
	{
		"folke/tokyonight.nvim",
		lazy = true,
		priority = 1000,
		config = function()
			local bg = "#011628"
			local bg_dark = "#011423"
			local bg_highlight = "#143652"
			local bg_search = "#0A64AC"
			local bg_visual = "#275378"
			local fg = "#CBE0F0"
			local fg_dark = "#B4D0E9"
			local fg_gutter = "#627E97"
			local border = "#547998"

			require("tokyonight").setup({
				style = "night",
				-- transparent = true,
				on_colors = function(colors)
					colors.bg = bg
					colors.bg_dark = bg_dark
					colors.bg_float = bg_dark
					colors.bg_highlight = bg_highlight
					colors.bg_popup = bg_dark
					colors.bg_search = bg_search
					colors.bg_sidebar = bg_dark
					colors.bg_statusline = bg_dark
					colors.bg_visual = bg_visual
					colors.border = border
					colors.fg = fg
					colors.fg_dark = fg_dark
					colors.fg_float = fg
					colors.fg_gutter = fg_gutter
					colors.fg_sidebar = fg_dark
				end,
				on_highlights = function(hl, c)
					local diff_add = "#2e3f34" -- Soft green
					local diff_delete = "#4b2c2e" -- Soft red
					local diff_change = "#1e2a3e" -- Soft blue
					local diff_text = "#394b70" -- Bright blue for word changes

					hl.DiffAdd = { bg = diff_add }
					hl.DiffDelete = { bg = diff_delete }
					hl.DiffChange = { bg = diff_change }
					hl.DiffText = { bg = diff_text }
					hl.Folded = { fg = c.comment, bg = "NONE" }

					-- This makes the "filler" lines (the '-' lines) disappear
					-- and look like a clean background instead.
					hl.DiffFiller = { fg = c.bg_dark, bg = c.bg_dark }
				end,
			})
		end,
	},

	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = true,
		priority = 1000,
		config = function()
			require("rose-pine").setup({
				-- disable_background = true,
			})
			-- Highlight Tree-sitter types differently
			-- vim.api.nvim_set_hl(0, "@lsp.type.class", { fg = "#569CD6" })
			vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = "#D19A66" })
		end,
	},

	{
		-- Omarchy's ristretto is monokai-pro's ristretto filter, which only
		-- applies through setup(), not by picking a colorscheme name.
		"gthelding/monokai-pro.nvim",
		lazy = true,
		priority = 1000,
		opts = { filter = "ristretto" },
	},

	{ "catppuccin/nvim", name = "catppuccin", lazy = true, priority = 1000 },
	{ "EdenEast/nightfox.nvim", lazy = true, priority = 1000 }, -- nord -> nordfox
	{ "rebelot/kanagawa.nvim", lazy = true, priority = 1000 },
	{ "ellisonleao/gruvbox.nvim", lazy = true, priority = 1000 },
	{ "neanias/everforest-nvim", lazy = true, priority = 1000 },
	{ "tahayvr/matteblack.nvim", lazy = true, priority = 1000 },
	{ "bjarneo/vantablack.nvim", lazy = true, priority = 1000 },
	{ "bjarneo/ethereal.nvim", lazy = true, priority = 1000 },
	{ "bjarneo/white.nvim", lazy = true, priority = 1000 },
	{ "bjarneo/hackerman.nvim", dependencies = { "bjarneo/aether.nvim" }, lazy = true, priority = 1000 },
	{ "kepano/flexoki-neovim", lazy = true, priority = 1000 },
	{ "omacom-io/lumon.nvim", lazy = true, priority = 1000 },
	{ "OldJobobo/miasma.nvim", lazy = true, priority = 1000 },
	{ "OldJobobo/retro-82.nvim", lazy = true, priority = 1000 },
	{ "ribru17/bamboo.nvim", lazy = true, priority = 1000 }, -- osaka-jade
	{ "ficcdaf/ashen.nvim", lazy = true, priority = 1000 }, -- solitude
}
