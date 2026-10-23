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
	config = function(_, opts)
		local hooks = require("ibl.hooks")
		-- No guides inside comments: ASCII diagrams in /* */ have leading
		-- whitespace that ibl would otherwise read as indentation. Probe col 0
		-- so a trailing `// note` on a code line doesn't skip it. Matches any
		-- comment node type (Odin: comment / block_comment).
		hooks.register(hooks.type.SKIP_LINE, function(_, bufnr, row, _)
			local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, 0 } })
			return ok and node ~= nil and node:type():find("comment") ~= nil
		end)
		require("ibl").setup(opts)
	end,
}
