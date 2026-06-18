return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		-- Register SQL dialects missing from Comment.nvim's built-in table
		local ft = require("Comment.ft")
		ft.set("mysql", { "--%s", "/*%s*/" })
		ft.set("plsql", { "--%s", "/*%s*/" })

		-- Neovim 0.12 changed get_parser() to return nil instead of erroring
		-- for unknown filetypes. Comment.nvim doesn't nil-check the result and
		-- crashes in ft.contains(). Wrap calculate() so any crash returns nil,
		-- letting Comment.nvim fall back to vim.bo.commentstring cleanly.
		local orig = ft.calculate
		ft.calculate = function(ctx)
			local ok, result = pcall(orig, ctx)
			return ok and result or nil
		end

		local comment = require("Comment")
		comment.setup()
	end,
}
