return {
	"saghen/blink.cmp",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			dependencies = { "rafamadriz/friendly-snippets" },
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
	},
	version = "1.*",

	opts = {
		keymap = {
			preset = "default",
			["<C-l>"] = { "snippet_forward", "fallback" },
			["<C-h>"] = { "snippet_backward", "fallback" },
		},

		snippets = { preset = "luasnip" },

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = {
			menu = {
				auto_show = true,
			},

			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
				window = {
					border = "rounded",
				},
			},

			accept = {
				auto_brackets = { enabled = true },
			},
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				sql = { "snippets", "dadbod", "buffer" },
				mysql = { "snippets", "dadbod", "buffer" },
				txt = { "buffer" },
			},
			providers = {
				dadbod = {
					name = "Dadbod",
					module = "vim_dadbod_completion.blink",
					score_offset = 100,
				},
			},
		},

		signature = {
			enabled = true,
		},

		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
