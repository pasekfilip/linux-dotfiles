return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		local set = vim.keymap.set

		harpoon:setup({})

		set("n", "<leader>a", function() harpoon:list():add() end)
		set("n", "<leader>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

		set("n", "<Left>", function() harpoon:list():select(1) end)
		set("n", "<Right>", function() harpoon:list():select(2) end)
		set("n", "<Up>", function() harpoon:list():select(3) end)
		set("n", "<Down>", function() harpoon:list():select(4) end)

		-- The list is already ordered and small, so this just needs fzf over a
		-- fixed table -- no finder/sorter plumbing like the telescope version.
		local function toggle_fzf(harpoon_files)
			local paths = vim.tbl_map(function(item)
				return item.value
			end, harpoon_files.items)

			require("fzf-lua").fzf_exec(paths, {
				prompt = "Harpoon> ",
				actions = { ["default"] = require("fzf-lua").actions.file_edit },
			})
		end

		set("n", "<C-e>", function() toggle_fzf(harpoon:list()) end, { desc = "Open harpoon window" })
	end,
}
