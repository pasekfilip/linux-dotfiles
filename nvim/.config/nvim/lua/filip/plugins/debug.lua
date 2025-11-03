return {
	-- {
	-- 	"Civitasv/cmake-tools.nvim",
	-- 	ft = { "cpp", "c", "cmake" },
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- 	config = function()
	-- 		require("cmake-tools").setup({
	-- 			cmake_command = "cmake",
	-- 			cmake_build_directory = "build",
	-- 			cmake_build_type = "Debug",
	-- 			cmake_generate_options = { "-G", "Ninja" }, -- or "MinGW Makefiles"
	-- 			cmake_regenerate_on_save = true,
	-- 		})
	-- 	end,
	-- },
	--
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
		"nvim-neotest/nvim-nio",
	},

	config = function()
		local dap = require("dap")

		dap.adapters.gdb = {
			type = "executable",
			command = "gdb",
			args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
		}
		dap.configurations.cpp = {
			{
				name = "Launch",
				type = "gdb",
				request = "launch",
				program = "C:/Filip/OpenGL/build/main.exe",
				cwd = 'C:/Filip/OpenGL/build',
				setupCommands =
				{
					description = "Enable pretty printing",
					text = "-enable-pretty-printing",
					ignoreFailures = true
				}
			},
			{
				name = "Select and attach to process",
				type = "gdb",
				request = "attach",
				program = function()
					return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
				end,
				pid = function()
					local name = vim.fn.input('Executable name (filter): ')
					return require("dap.utils").pick_process({ filter = name })
				end,
				cwd = '${workspaceFolder}'
			},
		}

		local set = vim.keymap.set
		set("n", "<F4>", dap.continue)
		set("n", "<F7>", dap.terminate)
		set("n", "<F9>", dap.toggle_breakpoint)
		set("n", "<F10>", dap.step_over)
		set("n", "<F11>", dap.step_into)

		local ui = require("dapui")
		ui.setup();

		dap.listeners.after.event_initialized["dapui_config"] = function()
			ui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			ui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			ui.close()
		end

		require("nvim-dap-virtual-text").setup {}
	end
}
