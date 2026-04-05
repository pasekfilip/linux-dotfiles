return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",

	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects" },
		"Badhi/nvim-treesitter-cpp-tools",
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
		local treesitter = require("nvim-treesitter.configs")

		treesitter.setup({
			highlight = {
				enable = true,
			},
			indent = {
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
				"java",
			},
			auto_install = true,
			sync_install = false,
			ignore_install = {},
			modules = {},
			textobjects = {
				move = {
					enable = true,
					set_jumps = true,
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[c"] = "@class.outer",
					},
					goto_next_start = {
						["]m"] = "@function.outer",
						["]c"] = "@class.outer",
					},
				},
			},
		})

		require("nt-cpp-tools").setup({
			preview = {
				quit = "q", -- quit preview window
				accept = "<c-y>", -- accept the proposed implementation
			},
			header_extension = "h", -- default header extension
			source_extension = "cpp", -- default source extension
			custom_define_class_function_commands = { -- provide custom commands
				TSCppImplWrite = {
					output_handle = require("nt-cpp-tools.output_handlers").get_add_to_cpp(),
				},
			},
		})

		vim.keymap.set("n", "<leader>cf", "<cmd>TSCppDefineClassFunc<cr>", { desc = "Draft Class Functions" })
		vim.keymap.set("v", "<leader>cf", ":TSCppDefineClassFunc<cr>", { desc = "Draft Selected Functions" })
		vim.keymap.set("n", "<leader>cm", "<cmd>TSCppMakeConcreteClass<cr>", { desc = "Make Concrete Class" })
	end,
}
