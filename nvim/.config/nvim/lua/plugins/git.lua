return {
	{
		-- Magit for nvim. Diffs are inline/unified only (no diffview), which
		-- suits a zoomed-in terminal better than side-by-side. Every view opens
		-- in the current window ("replace"); the defaults are tabs and vsplits.
		-- In the status: <Tab> expand a file's diff, s/u stage/unstage,
		-- c c commit, P p push, F p pull, ? for all keys, q to leave.
		"NeogitOrg/neogit",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim" },
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
