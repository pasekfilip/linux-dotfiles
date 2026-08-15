return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"igorlfs/nvim-dap-view",
		"williamboman/mason.nvim",
	},
	keys = {
		{
			"<leader>dc",
			function() require("dap").continue() end,
			desc = "Debug: Start/Continue",
		},
		{
			"<leader>dq",
			function() require("dap").terminate() end,
			desc = "Debug: Terminate",
		},
		{
			"<leader>dt",
			function() require("dap-view").toggle() end,
			desc = "Debug: Toggle View",
		},
		{
			"<leader>db",
			function() require("dap").toggle_breakpoint() end,
			desc = "Debug: Toggle Breakpoint",
		},
		{
			"<leader>dh",
			function() require("dap-view").hover() end,
			mode = { "n", "v" },
			desc = "Debug: Hover Value",
		},
		{
			"<leader>dw",
			function() require("dap-view").add_expr() end,
			mode = { "n", "v" },
			desc = "Debug: Watch Expression",
		},
		{
			"<leader>do",
			function() require("dap").step_over() end,
			desc = "Debug: Step Over",
		},
		{
			"<leader>di",
			function() require("dap").step_into() end,
			desc = "Debug: Step Into",
		},
		{
			"<leader>dO",
			function() require("dap").step_out() end,
			desc = "Debug: Step Out",
		},
	},
	config = function()
		local dap = require("dap")
		local dapview = require("dap-view")

		dapview.setup({
			auto_toggle = true, -- open on launch/attach, close when the session ends
			winbar = {
				-- Adding "console" merges the terminal into the main window instead
				-- of giving it its own split
				sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
			},
			virtual_text = {
				enabled = true,
				position = "eol",
			},
		})

		dap.adapters.java = function(callback)
			vim.lsp.buf_request(0, "workspace/executeCommand", {
				command = "vscode.java.startDebugSession",
			}, function(err, port)
				assert(not err, vim.inspect(err))
				callback({ type = "server", host = "127.0.0.1", port = port })
			end)
		end

		dap.configurations.java = {
			{
				type = "java",
				request = "attach",
				name = "Attach → Tomcat 9 (localhost:5005)",
				hostName = "127.0.0.1",
				port = 5005,
			},
		}

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.expand("$HOME/.local/share/nvim/mason/bin/codelldb"),
				args = { "--port", "${port}" },
			},
		}

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

		dap.configurations.odin = {
			{
				name = "Launch file",
				type = "codelldb",
				request = "launch",
				program = function()
					local result = vim.fn.system("odin build . -debug -out:render_buzz")

					if vim.v.shell_error ~= 0 then
						vim.notify("Compilation failed:\n" .. result)
						return nil
					end

					return vim.fn.getcwd() .. "/render_buzz"
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
		}
	end,
}
