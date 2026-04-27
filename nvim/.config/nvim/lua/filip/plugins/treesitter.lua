return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",

	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
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

	init = function()
		-- Enable treesitter highlighting and indentation via FileType autocmd
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				-- Enable treesitter highlighting and disable regex syntax
				pcall(vim.treesitter.start)
				-- Enable treesitter-based indentation
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		-- Install parsers that aren't already installed
		local ensureInstalled = {
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
		}

		local alreadyInstalled = require("nvim-treesitter.config").get_installed()
		local parsersToInstall = vim.iter(ensureInstalled)
			:filter(function(parser)
				return not vim.tbl_contains(alreadyInstalled, parser)
			end)
			:totable()

		if #parsersToInstall > 0 then
			require("nvim-treesitter").install(parsersToInstall)
		end
	end,

	config = function()
		-- Configure textobjects (new API for main branch)
		require("nvim-treesitter-textobjects").setup({
			move = {
				set_jumps = true, -- whether to set jumps in the jumplist
			},
		})

		-- Set up textobject movement keymaps
		local ts_move = require("nvim-treesitter-textobjects.move")

		-- Jump to next function/class start
		vim.keymap.set({ "n", "x", "o" }, "]m", function()
			ts_move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function start" })

		vim.keymap.set({ "n", "x", "o" }, "]c", function()
			ts_move.goto_next_start("@class.outer", "textobjects")
		end, { desc = "Next class start" })

		-- Jump to previous function/class start
		vim.keymap.set({ "n", "x", "o" }, "[m", function()
			ts_move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Previous function start" })

		vim.keymap.set({ "n", "x", "o" }, "[c", function()
			ts_move.goto_previous_start("@class.outer", "textobjects")
		end, { desc = "Previous class start" })

		-- Configure C++ tools
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

		-- Set up keymaps for C++ tools
		vim.keymap.set("n", "<leader>cf", "<cmd>TSCppDefineClassFunc<cr>", { desc = "Draft Class Functions" })
		vim.keymap.set("v", "<leader>cf", ":TSCppDefineClassFunc<cr>", { desc = "Draft Selected Functions" })
		vim.keymap.set("n", "<leader>cm", "<cmd>TSCppMakeConcreteClass<cr>", { desc = "Make Concrete Class" })
	end,
}
