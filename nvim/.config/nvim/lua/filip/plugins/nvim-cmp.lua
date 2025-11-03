return {
    'saghen/blink.cmp',
    dependencies = {
        'rafamadriz/friendly-snippets',
    },
    version = '1.*',

    opts = {
        keymap = {
            preset = 'default',
            ['<C-l>'] = { 'snippet_forward', 'fallback' },
            ['<C-h>'] = { 'snippet_backward', 'fallback' },
            -- ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
            -- ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        },

        appearance = {
            nerd_font_variant = 'mono'
        },

        completion =
        {
            documentation = { auto_show = true, auto_show_delay_ms = 500 },
            accept = {
                auto_brackets = { enabled = true },     -- Disable parentheses for functions in PowerShell
            }
        },

        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
            per_filetype = {
                sql = { 'snippets', 'dadbod', 'buffer' },
                mysql = { 'snippets', 'dadbod', 'buffer' },
                txt = { 'buffer' },
            },
            providers = {
                dadbod = {
                    name = "Dadbod",
                    module = "vim_dadbod_completion.blink",
                    score_offset = 100,
                }
            },
        },

        signature = { enabled = true },
        fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" },
}



-- return {
-- 	"hrsh7th/nvim-cmp",
-- 	lazy = false,
-- 	priority = 100,
-- 	dependencies = {
-- 		'onsails/lspkind.nvim',
-- 		"hrsh7th/cmp-buffer",
-- 		"hrsh7th/cmp-path",
-- 		{ "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
-- 		"saadparwaiz1/cmp_luasnip",
-- 		"rafamadriz/friendly-snippets",
-- 	},
--
-- 	config = function()
-- 		local cmp = require("cmp")
-- 		local luasnip = require("luasnip")
-- 		local lspkind = require("lspkind")
--
-- 		local kind_formatter = lspkind.cmp_format {
-- 			mode = "symbol_text",
-- 			menu = {
-- 				buffer = "[buf]",
-- 				nvim_lsp = "[LSP]",
-- 				nvim_lua = "[api]",
-- 				path = "[path]",
-- 				luasnip = "[snip]",
-- 				gh_issues = "[issues]",
-- 				tn = "[TabNine]",
-- 				eruby = "[erb]",
-- 			},
-- 		}
--
-- 		cmp.setup({
-- 			snippet = { -- configure how nvim-cmp interacts with snippet engine
-- 				expand = function(args)
-- 					luasnip.lsp_expand(args.body)
-- 				end,
-- 			},
--
-- 			completion = {
-- 				completeopt = "menu,menuone",
-- 			},
--
-- 			window = {
-- 				completion = cmp.config.window.bordered(),
-- 				documentation = cmp.config.window.bordered()
-- 			},
--
-- 			mapping = {
-- 				["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
-- 				["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
-- 				["<C-f>"] = cmp.mapping.scroll_docs(-4),
-- 				["<C-g>"] = cmp.mapping.scroll_docs(4),
-- 				-- ["<C-@>"] = cmp.mapping.complete(),
-- 				["<C-e>"] = cmp.mapping.abort(),
-- 				["<C-y>"] = cmp.mapping(
-- 					cmp.mapping.confirm {
-- 						behavior = cmp.ConfirmBehavior.Insert,
-- 						select = true,
-- 					},
-- 					{ "i", "c" }
-- 				),
-- 			},
--
-- 			-- sources for autocompletion
-- 			sources = {
-- 				{ name = "nvim_lsp" },
-- 				{ name = "luasnip" }, -- snippets
-- 				{ name = "buffer" }, -- text within current buffer
-- 				{ name = "path" }, -- file system paths
-- 			},
--
-- 			formatting = {
-- 				fields = { "abbr", "kind", "menu" },
-- 				expandable_indicator = true,
-- 				format = function(entry, vim_item)
-- 					-- Lspkind setup for icons
-- 					vim_item = kind_formatter(entry, vim_item)
--
--
-- 					-- Tailwind colorizer setup
-- 					-- vim_item = require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
--
-- 					return vim_item
-- 				end,
-- 			},
-- 		})
--
-- 		vim.keymap.set({ "i", "s" }, "<c-l>", function()
-- 			if luasnip.expand_or_jumpable() then
-- 				luasnip.expand_or_jump()
-- 			end
-- 		end, { silent = true })
--
-- 		vim.keymap.set({ "i", "s" }, "<c-h>", function()
-- 			if luasnip.jumpable(-1) then
-- 				luasnip.jump(-1)
-- 			end
-- 		end, { silent = true })
-- 	end,
-- }
