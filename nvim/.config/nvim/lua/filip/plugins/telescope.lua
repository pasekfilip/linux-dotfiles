return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--trim", -- Helps with speed by trimming indentation
				},
				file_ignore_patterns = {
					"%.class", -- Java compiled classes
					"target/", -- Maven/Spring build folder
					"build/", -- Gradle build folder
					"node_modules", -- If you have frontend
					".git/",
					".settings/",
					".metadata/",
					"%.jar",
					"%.war",
				},
				mappings = {
					i = {
						["<C-h>"] = function(prompt_bufnr)
							local prompt = require("telescope.actions.state").get_current_line()
							actions.close(prompt_bufnr)

							builtin.find_files({
								hidden = true,
								default_text = prompt,
							})
						end,
						["<C-s>"] = actions.select_vertical,
					},
				},
			},
			-- 3. ADD THIS: Tell FZF to override the default Lua sorter
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
			pickers = {
				-- Optimization: use built-in find_files logic
				find_files = {
					find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
				},
			},
		})

		telescope.load_extension("fzf")

		-- ... your keymaps stay the same ...
		local keymap = vim.keymap
		keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
		keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Get diagnostics" })
		keymap.set("n", "<leader>fe", function()
			builtin.diagnostics({ severity = "ERROR" })
		end, { desc = "Workspace Errors" })
		keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help tags" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
	end,
}
