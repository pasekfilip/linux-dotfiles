return {
	"akinsho/bufferline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	enabled = false,
	version = "*",
	config = function()
		local bufferline = require('bufferline')
		local keymap = vim.keymap -- for conciseness

		-- keymap.set("n", "<leader>hhho", "<cmd>tabnew<CR>", { desc = "Open new tab" })
		keymap.set("n", "<leader>w", "<cmd>q<CR>", { desc = "Close current window" })
		keymap.set("n", "<Tab>", "<cmd>tabnext<CR>", { desc = "Go to next tab" })
		keymap.set("n", "<S-Tab>", "<cmd>tabprevious<CR>", { desc = "Go to previous tab" })
		-- keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

		bufferline.setup({
			options = {
				mode = "tabs",
				numbers = "none",
				indicator = {
					icon = '▎',
					style = 'icon'
				},
				offsets = {
					{
						filetype = "neo-tree",
						text = "File Explorer",
						separator = true
					}
				},
				separator_style = "slant",
				hover = {
					enabled = true,
					delay = 200,
					reveal = { 'close' }
				},
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level, diagnostics_dict, context)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
			}
		})
	end
}
