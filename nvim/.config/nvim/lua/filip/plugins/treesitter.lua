return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",

	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects" },
		{
			"windwp/nvim-ts-autotag",
			lazy = true
		},
		-- {
		-- 	"nvim-treesitter/nvim-treesitter-context",
		-- 	lazy = true,   -- load only after Treesitter is ready
		-- 	opts = {       -- passed straight to require("treesitter-context").setup()
		-- 		enable     = true,
		-- 		max_lines  = 3, -- show up to three lines of context
		-- 		trim_scope = "outer", -- drop outer scopes first when max_lines is hit
		-- 		mode       = "cursor", -- update when cursor moves (default)
		-- 		separator  = nil, -- you can set "―" or "─" if you want a visual separator
		-- 	},
		-- },
	},

	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		treesitter.setup({
			highlight = {
				enable = true
			},
			indent = {
				enable = true
			},
			autotag = {
				enable = true,
			},
			ensure_installed = {
				"gdscript",
				"godot_resource",
				"json",
				"javascript",
				"typescript",
				"yaml",
				"html",
				"css",
				"markdown",
				"markdown_inline",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"c_sharp",
				"cpp",
				"python",
				"java"
			},
			auto_install = false,
			sync_install = true,
			ignore_install = {},
			modules = {},
			textobjects = {
				move = {
					enable = true,
					set_jumps = true, -- adds to jumplist
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[c"] = "@class.outer",
					},
					goto_next_start = {
						["]m"] = "@function.outer",
						["]c"] = "@class.outer",
					},
				},
			}
			-- incremental_selection = {
			-- 	enable = true,
			-- 	keymaps = {
			-- 		init_selection = "<C-space>",
			-- 		node_incremental = "<C-space>",
			-- 		scope_incremental = false,
			-- 		node_decremental = "<bs>",
			-- 	},
			-- },
		})
		-- vim.api.nvim_set_hl(0, "@type.class", { fg = "#88C0D0" }) -- blue-ish
		-- vim.api.nvim_set_hl(0, "@type.enum", { fg = "#EBCB8B" }) -- yellow-ish
	end,
}
