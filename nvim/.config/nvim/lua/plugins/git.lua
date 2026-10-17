return {
	{
		"tpope/vim-fugitive",
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
