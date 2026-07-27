return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	opts = {
		-- Scope every kulala keymap to http/rest buffers so the <leader>i prefix
		-- doesn't clash with the global <leader>i task-popup toggle. By default
		-- these 5 have no `ft` and bind globally, turning <leader>i into an
		-- ambiguous prefix everywhere (task toggle then waits for timeoutlen).
		global_keymaps = {
			["Open scratchpad"] = {
				"<leader>ib",
				function()
					require("kulala").scratchpad()
				end,
				ft = { "http", "rest" },
			},
			["Open kulala"] = {
				"<leader>io",
				function()
					require("kulala").open()
				end,
				ft = { "http", "rest" },
			},
			["Send request"] = {
				"<leader>is",
				function()
					require("kulala").run()
				end,
				mode = { "n", "v" },
				ft = { "http", "rest" },
			},
			["Send all requests"] = {
				"<leader>ia",
				function()
					require("kulala").run_all()
				end,
				mode = { "n", "v" },
				ft = { "http", "rest" },
			},
			["Replay the last request"] = {
				"<leader>ir",
				function()
					require("kulala").replay()
				end,
				ft = { "http", "rest" },
			},
		},
		global_keymaps_prefix = "<leader>i",
		kulala_keymaps_prefix = "",
		-- Kulala's default in-window keymaps bind <C-h>/<C-l> to prev/next tab,
		-- which shadows vim-tmux-navigator's window navigation inside the kulala
		-- view. Move tab switching to <S-Tab>/<Tab> so <C-h>/<C-l> stay free.
		kulala_keymaps = {
			["Previous tab"] = {
				"<S-Tab>",
				function()
					require("kulala.ui").show_previous_tab()
				end,
				mode = { "n" },
			},
			["Next tab"] = {
				"<Tab>",
				function()
					require("kulala.ui").show_next_tab()
				end,
				mode = { "n" },
			},
		},
	},
}
