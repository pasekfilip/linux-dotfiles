return {
	"mrjones2014/smart-splits.nvim",
	-- must load eagerly so the IS_NVIM user var is set for wezterm to detect us
	lazy = false,
	opts = {
		ignored_filetypes = { "NvimTree" },
		default_amount = 5,
		at_edge = "stop",
	},
	keys = {
		-- move between nvim splits and wezterm panes with the same keys
		{
			"<C-h>",
			function()
				require("smart-splits").move_cursor_left()
			end,
			desc = "Move to split/pane left",
		},
		{
			"<C-j>",
			function()
				require("smart-splits").move_cursor_down()
			end,
			desc = "Move to split/pane down",
		},
		{
			"<C-k>",
			function()
				require("smart-splits").move_cursor_up()
			end,
			desc = "Move to split/pane up",
		},
		{
			"<C-l>",
			function()
				require("smart-splits").move_cursor_right()
			end,
			desc = "Move to split/pane right",
		},

		-- resize nvim splits and wezterm panes with the same keys.
		-- <M-*> is what wezterm forwards when you press CTRL+SHIFT+hjkl (see wezterm.lua),
		-- <C-S-*> is the direct key for terminals that speak the kitty keyboard protocol.
		{
			"<M-h>",
			function()
				require("smart-splits").resize_left()
			end,
			desc = "Resize split/pane left",
		},
		{
			"<M-j>",
			function()
				require("smart-splits").resize_down()
			end,
			desc = "Resize split/pane down",
		},
		{
			"<M-k>",
			function()
				require("smart-splits").resize_up()
			end,
			desc = "Resize split/pane up",
		},
		{
			"<M-l>",
			function()
				require("smart-splits").resize_right()
			end,
			desc = "Resize split/pane right",
		},
		{
			"<C-S-h>",
			function()
				require("smart-splits").resize_left()
			end,
			desc = "Resize split/pane left",
		},
		{
			"<C-S-j>",
			function()
				require("smart-splits").resize_down()
			end,
			desc = "Resize split/pane down",
		},
		{
			"<C-S-k>",
			function()
				require("smart-splits").resize_up()
			end,
			desc = "Resize split/pane up",
		},
		{
			"<C-S-l>",
			function()
				require("smart-splits").resize_right()
			end,
			desc = "Resize split/pane right",
		},

		-- swap buffers between splits (replaces <C-w>x, since <C-w> is mapped to :q)
		{
			"<leader><leader>h",
			function()
				require("smart-splits").swap_buf_left()
			end,
			desc = "Swap buffer left",
		},
		{
			"<leader><leader>j",
			function()
				require("smart-splits").swap_buf_down()
			end,
			desc = "Swap buffer down",
		},
		{
			"<leader><leader>k",
			function()
				require("smart-splits").swap_buf_up()
			end,
			desc = "Swap buffer up",
		},
		{
			"<leader><leader>l",
			function()
				require("smart-splits").swap_buf_right()
			end,
			desc = "Swap buffer right",
		},
	},
}
