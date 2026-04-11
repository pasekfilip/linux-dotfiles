return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"williamboman/mason.nvim",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local virtual_text = require("nvim-dap-virtual-text")

		dapui.setup()
		virtual_text.setup({
			enabled = true, -- enable this plugin (default)
			enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, etc.
			highlight_changed_variables = true, -- highlight changed values with a different color
			highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables
			show_stop_reason = true, -- show stop reason when stopped on a breakpoint
			commented = true, -- prefix virtual text with comment string
			only_manually_hidden = false, -- only hide virtual text when issued a command
			-- virt_text_pos = 'eol',              -- position of virtual text, see `:h nvim_buf_set_extmark()`
		})

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.expand("$HOME/.local/share/nvim/mason/bin/codelldb"),
				args = { "--port", "${port}" },
			},
		}

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "codelldb",
				request = "launch",
				program = function()
					local result = vim.fn.system("make")

					if vim.v.shell_error ~= 0 then
						vim.notify("Compilation failed:\n" .. result)
						return nil
					end

					return require("dap.utils").pick_file()
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				-- If you need to pass arguments;
				-- args = {"--fullscreen"},
			},
		}

		local set = vim.keymap.set
		set("n", "<F4>", dap.continue, { desc = "Debug: Start/Continue" })
		set("n", "<F7>", dap.terminate, { desc = "Debug: Terminate" })
		set("n", "<F8>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
		set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
		set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
		set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
	end,
}
