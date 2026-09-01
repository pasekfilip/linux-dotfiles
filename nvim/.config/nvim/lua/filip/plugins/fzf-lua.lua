-- Replaces telescope.nvim. Defaults are left alone except for two things that
-- actually break without config.
local IGNORE = { "target", "build", "node_modules", ".git", ".settings", ".metadata", "*.class", "*.jar", "*.war" }

local fd_opts = "--color=never --type f --type l"
local rg_opts = "--column --line-number --no-heading --color=always --smart-case"
for _, pat in ipairs(IGNORE) do
	fd_opts = fd_opts .. (" --exclude '%s'"):format(pat)
	rg_opts = rg_opts .. (" -g '!%s'"):format(pat)
end

return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "FzfLua",
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Fuzzy find files in cwd" },
		{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Fuzzy find recent files" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
		{ "<leader>fs", "<cmd>FzfLua live_grep<cr>", desc = "Find string in cwd" },
		{ "<leader>fc", "<cmd>FzfLua grep_cword<cr>", desc = "Find string under cursor in cwd" },
		{ "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Find help tags" },
		{ "<leader>ft", "<cmd>TodoFzfLua<cr>", desc = "Find todos" },
		{
			"<leader>fp",
			function()
				local list = vim.fn.systemlist("zoxide query -l")
				vim.ui.select(list, {}, function(choice)
					if not choice then
						return
					end
					vim.cmd("cd " .. vim.fn.fnameescape(choice))
					require("oil").open(choice)
				end)
			end,
			desc = "Switch project session",
		},
	},
	config = function()
		local fzf = require("fzf-lua")

		fzf.setup({
			winopts = { preview = { hidden = true } },
			files = { fd_opts = fd_opts },
			grep = { rg_opts = rg_opts },
			actions = {
				files = {
					[1] = true,
					["ctrl-q"] = fzf.actions.file_sel_to_qf,
					["ctrl-h"] = { fn = fzf.actions.toggle_hidden, reuse = true },
				},
			},
		})

		fzf.register_ui_select()
	end,
}
