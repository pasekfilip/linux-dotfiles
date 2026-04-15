return {
	{
		"shaunsingh/nord.nvim",
		enabled = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
	{
		"folke/tokyonight.nvim",
		enabled = true,
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

			-- load the colorscheme here
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
	{
		"rose-pine/neovim",
		enabled = false,
		name = "rose-pine",
		priority = 1000,
		config = function()
			require("rose-pine").setup({
				-- disable_background = true,
			})
			vim.cmd("colorscheme rose-pine")
			-- Highlight Tree-sitter types differently
			-- vim.api.nvim_set_hl(0, "@lsp.type.class", { fg = "#569CD6" })
			vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = "#D19A66" })
		end,
	},
}
