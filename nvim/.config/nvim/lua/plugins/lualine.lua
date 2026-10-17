return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	priority = 100,
	config = function()
		local lualine = require("lualine")

		-- "auto" derives the statusline from the active colorscheme, so it
		-- follows the Omarchy theme. lualine re-runs setup() on ColorScheme,
		-- which is what makes a live theme switch recolour the bar too.
		-- (This replaced a hardcoded blue/teal-on-#112638 palette.)
		lualine.setup({
			options = {
				theme = "auto",
			},
			sections = {
				-- Default minus 'diff': no added/changed/removed line counts.
				lualine_b = { "branch", "diagnostics" },
				lualine_x = {
					{
						function()
							return os.date("%H:%M")
						end
					}
				},
				lualine_y = {
					'filetype',
				},
				lualine_z = {
					'progress'
				},
			},
		})
	end,
}
