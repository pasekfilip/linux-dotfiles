return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<leader>t", "<cmd>ToggleTerm<CR>" },
			-- { "t", "<Esc>", "<C-\\><C-n>" },
		},
		config = function()
			require("toggleterm").setup({
				size = 50,
				-- open_mapping = [[<C-/]],
				shading_factor = 2,
				direction = "float",
				close_on_exit = true,
			})
		end,
	},
}
