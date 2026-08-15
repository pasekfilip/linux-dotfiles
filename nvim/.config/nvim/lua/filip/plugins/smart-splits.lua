return {
	"mrjones2014/smart-splits.nvim",
	-- must load eagerly so the IS_NVIM user var is set for wezterm to detect us
	lazy = false,
	opts = {
		ignored_filetypes = { "NvimTree" },
		default_amount = 5,
		at_edge = "wrap",
	},
	keys = {
		-- move between nvim splits and wezterm panes with the same keys
		{ "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to split/pane left" },
		{ "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to split/pane down" },
		{ "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to split/pane up" },
		{ "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to split/pane right" },

		-- resize nvim splits and wezterm panes with the same keys
		{ "<C-S-h>", function() require("smart-splits").resize_left() end, desc = "Resize split/pane left" },
		{ "<C-S-j>", function() require("smart-splits").resize_down() end, desc = "Resize split/pane down" },
		{ "<C-S-k>", function() require("smart-splits").resize_up() end, desc = "Resize split/pane up" },
		{ "<C-S-l>", function() require("smart-splits").resize_right() end, desc = "Resize split/pane right" },

		-- swap buffers between splits (replaces <C-w>x, since <C-w> is mapped to :q)
		{ "<leader><leader>h", function() require("smart-splits").swap_buf_left() end, desc = "Swap buffer left" },
		{ "<leader><leader>j", function() require("smart-splits").swap_buf_down() end, desc = "Swap buffer down" },
		{ "<leader><leader>k", function() require("smart-splits").swap_buf_up() end, desc = "Swap buffer up" },
		{ "<leader><leader>l", function() require("smart-splits").swap_buf_right() end, desc = "Swap buffer right" },
	},
}
