return {
	"windwp/nvim-autopairs",
	enabled = false,
	event = { "InsertEnter" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		-- Don't pair inside strings/comments (needs treesitter highlighting,
		-- which treesitter.lua starts per-buffer on FileType)
		check_ts = true,
		ts_config = {
			lua = { "string" },
			javascript = { "template_string" },
			java = false,
		},

		-- Skip the closing char when the line already has an unbalanced one,
		-- e.g. typing ( in `foo|)` won't give you `foo()|)`
		enable_check_bracket_line = true,

		-- Never auto-close right before a word, quote, bracket or dot. This is
		-- what kills most of the "why did it do that" moments.
		ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],

		-- <C-q> wraps the text after the cursor in the pair you just opened.
		-- Not Alt-anything: Hyprland owns alt as its window modifier.
		fast_wrap = {
			map = "<C-q>",
			chars = { "{", "[", "(", '"', "'", "`" },
			end_key = "$",
			keys = "qwertyuiopzxcvbnmasdfghjkl",
			check_comma = true,
			highlight = "Search",
			highlight_grey = "Comment",
		},

		disable_filetype = { "vim", "spectre_panel", "grug-far" },
	},
}
