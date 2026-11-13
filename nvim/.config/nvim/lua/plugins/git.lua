return {
	{
		-- Added/changed/deleted lines in the sign column, vs. the index.
		-- Colors come from omarchy_palette.lua (GitSigns* groups).
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- Signs are hidden until toggled with <leader>ht. Hunks are still
			-- tracked, so the maps below work either way.
			signcolumn = false,
			on_attach = function(buf)
				local gs = require("gitsigns")
				local function map(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
				end
				map("]h", function() gs.nav_hunk("next") end, "Next git hunk")
				map("[h", function() gs.nav_hunk("prev") end, "Prev git hunk")
				map("<leader>hp", gs.preview_hunk_inline, "Preview hunk inline")
				map("<leader>hr", gs.reset_hunk, "Reset hunk")
				map("<leader>hs", gs.stage_hunk, "Stage hunk")
				map("<leader>hb", gs.blame_line, "Blame line")
				map("<leader>ht", gs.toggle_signs, "Toggle git signs")
			end,
		},
	},
	{
		-- Magit for nvim. Its own diffs are inline/unified, which suits a
		-- zoomed-in terminal; the d popup hands off to diffview (below) for a
		-- side-by-side review. Every view opens in the current window
		-- ("replace"); the defaults are tabs and vsplits.
		-- In the status: <Tab> expand a file's diff, s/u stage/unstage,
		-- c c commit, P p push, F p pull, ? for all keys, q to leave.
		"NeogitOrg/neogit",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
		cmd = "Neogit",
		keys = {
			{ "<leader>gs", "<cmd>Neogit<cr>", desc = "Git status (Neogit)" },
			{ "<leader>gl", "<cmd>NeogitLog<cr>", desc = "Git log for the current file" },
		},
		opts = {
			kind = "replace",
			commit_editor = { kind = "replace" },
			commit_select_view = { kind = "replace" },
			commit_view = { kind = "replace" },
			log_view = { kind = "replace" },
			reflog_view = { kind = "replace" },
			stash = { kind = "replace" },
			refs_view = { kind = "replace" },
		},
	},
	{
		-- GitHub-review style: file list on the left, side-by-side diff of the
		-- selected file on the right, in its own tab. <Tab>/<S-Tab> step
		-- through files, g? lists the keys, <leader>gq closes the tab.
		--   :DiffviewOpen              working tree vs. index
		--   :DiffviewOpen main...HEAD  what a PR from this branch would show
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Review changes (Diffview)" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "History of the current file (Diffview)" },
			{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
		},
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		init = function()
			-- Full screen instead of the default 0.9 float.
			vim.g.lazygit_floating_window_scaling_factor = 1

			-- plugin/keymaps.lua maps terminal <Esc> to leave terminal mode,
			-- which would eat every Esc lazygit itself needs (closing panels,
			-- cancelling). A buffer-local map wins over the global one, so
			-- here Esc goes straight through to lazygit.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "lazygit",
				callback = function(ev)
					vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = ev.buf })
				end,
			})
		end,
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
		},
	},
}
