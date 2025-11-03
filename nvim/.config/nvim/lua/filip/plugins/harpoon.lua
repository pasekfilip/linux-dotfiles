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

		-- basic telescope configuration
		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers").new({}, {
				prompt_title = "Harpoon",
				finder = require("telescope.finders").new_table({
					results = file_paths,
				}),
				previewer = conf.file_previewer({}),
				sorter = conf.generic_sorter({}),
			}):find()
		end

		set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
			{ desc = "Open harpoon window" })
	end,
}
