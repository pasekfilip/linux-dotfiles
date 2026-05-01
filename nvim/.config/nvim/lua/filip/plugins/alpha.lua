return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			"                        私                  ",
			"                      私  私                ",
			"                     私    私               ",
			"                    私      私              ",
			"                   私        私             ",
			"                  私          私            ",
			"                 私私私私私私私私           ",
			"                謙虚な人を目指したい        ",
		}

		dashboard.section.buttons.val = {
			dashboard.button("e", "  新しいファイル", "<cmd>ene <BAR> startinsert <cr>"),
			dashboard.button("s", "󱑒  Restore Session", [[<cmd>lua require("persistence").load()<cr>]]),
			dashboard.button("d", "  Database UI (Dadbod)", "<cmd>DBUIToggle<cr>"),
			dashboard.button("p", "  Find Project", "<cmd>Telescope find_files<cr>"),
			dashboard.button("q", "󰅚  終了(しゅうりょう)", "<cmd>qa<cr>"),
		}

		local stats = require("lazy").stats()
		dashboard.section.footer.val = "⚡ Loaded " .. stats.count .. " plugins"

		-- Send config to alpha
		alpha.setup(dashboard.opts)
	end,
}
