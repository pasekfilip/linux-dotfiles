return {
	"lukas-reineke/indent-blankline.nvim",
	-- Not BufReadPre: ibl.setup() runs nvim_win_call over every window, which
	-- switches curbuf mid-read and raises E201 when another window is open
	-- (e.g. bufload() from the task popup while on alpha).
	event = { "BufReadPost", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = { char = "┊" },
		exclude = { filetypes = { "markdown" } },
	},
}
