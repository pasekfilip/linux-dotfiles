return {
	"MagicDuck/grug-far.nvim",
	-- The editable half of grep: results land in a buffer you edit, and writing
	-- it applies the replacements across every file. Quickfix (]q/[q) walks
	-- matches; this one rewrites them.
	keys = {
		{ "<leader>fR", function() require("grug-far").open() end, desc = "Search & replace in cwd" },
		{ "<leader>fR", function() require("grug-far").with_visual_selection() end, mode = "v", desc = "Search & replace selection" },
	},
	opts = {},
}
