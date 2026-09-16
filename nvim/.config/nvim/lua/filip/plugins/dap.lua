return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"igorlfs/nvim-dap-view",
		"williamboman/mason.nvim",
	},
	keys = {
		{
			"<F4>",
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
			"<F5>",
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
			"<F10>",
			function() require("dap").step_over() end,
			desc = "Debug: Step Over",
		},
		{
			"<F11>",
			function() require("dap").step_into() end,
			desc = "Debug: Step Into",
		},
		{
			"<S-F11>",
			function() require("dap").step_out() end,
			desc = "Debug: Step Out",
		},
	},
	config = function()
		local dap = require("dap")
		local dapview = require("dap-view")

		dapview.setup({
			auto_toggle = true,
			winbar = {
				sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
			},
			virtual_text = {
				enabled = true,
				position = "eol",
			},
		})

		local java_debug_settings = vim.json.encode({
			logLevel = "WARNING",
			showToString = false,
			showLogicalStructure = true,
			showStaticVariables = false,
			showQualifiedNames = false,
			maxStringLength = 500,
		})

		local function maven_project_name()
			local pom = vim.fs.find("pom.xml", { upward = true, path = vim.fn.expand("%:p:h") })[1]

			if not pom then
				return nil
			end

			local xml = table.concat(vim.fn.readfile(pom), "\n"):gsub("<parent>.-</parent>", "")

			return xml:match("<artifactId>%s*(.-)%s*</artifactId>")
		end

		dap.adapters.java = function(callback)
			vim.lsp.buf_request(0, "workspace/executeCommand", {
				command = "vscode.java.updateDebugSettings",
				arguments = { java_debug_settings },
			}, function(err)
				if err then
					vim.notify("java debug settings: " .. vim.inspect(err), vim.log.levels.WARN)
				end
			end)

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
				projectName = maven_project_name,
				stepFilters = {
					skipSynthetics = true,
					skipStaticInitializers = true,
					skipConstructors = true,
					classNameFilters = {
						"java.*",
						"javax.*",
						"jdk.*",
						"sun.*",
						"org.springframework.*",
						"org.apache.*",
						"org.hibernate.*",
						"com.sun.proxy.*",
						"*$$EnhancerBySpringCGLIB*",
						"*$$FastClassBySpringCGLIB*",
					},
				},
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

		dap.configurations.asm = {
			{
				name = "Launch file",
				type = "codelldb",
				request = "launch",
				program = function()
					local cwd = vim.fn.getcwd()
					local obj = vim.fn.system("nasm -f elf64 -g -F dwarf " .. cwd .. "/main.asm -o " .. cwd .. "/main.o")

					if vim.v.shell_error ~= 0 then
						vim.notify("Assembly failed:\n" .. obj)
						return nil
					end

					local link = vim.fn.system("ld " .. cwd .. "/main.o -o " .. cwd .. "/main")

					if vim.v.shell_error ~= 0 then
						vim.notify("Linking failed:\n" .. link)
						return nil
					end

					return cwd .. "/main"
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = true,
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
