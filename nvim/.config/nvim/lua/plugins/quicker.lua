return {
	"stevearc/quicker.nvim",
	-- The quickfix window itself becomes editable: change lines and :w writes
	-- them back to their files, delete a line to drop that entry.
	ft = "qf",
	---@module "quicker"
	---@type quicker.SetupOptions
	opts = {
		-- buffer-local to the qf window, so they don't shadow > / < elsewhere
		keys = {
			{
				">",
				function()
					require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
				end,
				desc = "Expand quickfix context",
			},
			{
				"<",
				function()
					require("quicker").collapse()
				end,
				desc = "Collapse quickfix context",
			},
		},
	},
}
