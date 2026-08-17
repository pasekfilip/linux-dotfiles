return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
	},
	config = function()
		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("blink.cmp")

		local keymap = vim.keymap

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(event)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local buf = event.buf
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				local opts = { buffer = buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", vim.lsp.buf.implementation, opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end, opts)

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Show signature help"
				keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts) -- show documentation for what is under cursor

				-- opts.desc = "Restart LSP"
				-- keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

				if client and client.server_capabilities.documentFormattingProvider then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("LspFormat", { clear = true }),
						buffer = buf,
						callback = function()
							vim.lsp.buf.format({ bufnr = buf })
						end,
					})
				end
			end,
		})

		vim.diagnostic.config({
			underline = true,
			-- No inline/virtual rendering: nothing shifts the buffer text around.
			-- Diagnostics show as gutter signs; the message is a float you ask for
			-- with <leader>ld (or that follows [d / ]d).
			virtual_text = false,
			virtual_lines = false,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.INFO] = "",
					[vim.diagnostic.severity.HINT] = "󰠠",
				},
			},
			update_in_insert = false,
			severity_sort = true,
			float = {
				border = "rounded",
				source = true,
				header = "",
				prefix = "",
				focusable = true,
			},
		})

		-- On demand only, focusable so the popup can be scrolled / yanked from.
		keymap.set("n", "<leader>ld", function()
			vim.diagnostic.open_float(nil, { scope = "line", focus = true })
		end, { desc = "Show line diagnostics" })

		-- Set your Java path
		local java_exec = "/usr/lib/jvm/default-runtime/bin/java"

		-- java-debug-adapter bundle (installed via Mason or auto-installed in debug.lua)
		local debug_jar = vim.fn.glob(
			vim.fn.stdpath("data")
				.. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
			true
		)
		local bundles = {}
		if debug_jar ~= "" then
			table.insert(bundles, debug_jar)
		end

		-- Find the JAR file installed by Mason
		local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
		local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
		local config_dir = jdtls_path .. "/config_linux" -- use config_linux / config_mac if needed

		local function java_root(fname)
			-- Prefer the repository / build root for multi-module projects so JDTLS
			-- imports sibling modules into the same workspace. Falling back directly to
			-- pom.xml/build.gradle would often start JDTLS inside just one submodule.
			local multi_module_root = vim.fs.root(fname, {
				"mvnw",
				"gradlew",
				"settings.gradle",
				"settings.gradle.kts",
				".git",
			})
			local single_module_root = vim.fs.root(fname, {
				"pom.xml",
				"build.gradle",
				"build.gradle.kts",
				"build.xml",
			})

			return multi_module_root or single_module_root or vim.fn.getcwd()
		end

		vim.lsp.config("jdtls", {
			init_options = {
				bundles = bundles, -- enables vscode.java.startDebugSession command
			},
			-- In Nvim 0.12, a function-valued `cmd` must start and return the RPC client.
			-- Returning only the argv table makes client.rpc a plain table, which causes
			-- `attempt to call field 'request' (a nil value)` during initialize.
			cmd = function(dispatchers, config)
				local root = config.root_dir or java_root(0)
				local ws_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":p:t")

				local cmd = {
					java_exec,
					"-javaagent:" .. jdtls_path .. "/lombok.jar",
					"-Declipse.application=org.eclipse.jdt.ls.core.id1",
					"-Dosgi.bundles.defaultStartLevel=4",
					"-Declipse.product=org.eclipse.jdt.ls.core.product",
					"-Dlog.protocol=true",
					"-Dlog.level=ALL",
					"-Xmx4g",
					"-XX:+UseG1GC",
					"-XX:+UseStringDeduplication",
					"--add-modules=ALL-SYSTEM",
					"--add-opens",
					"java.base/java.util=ALL-UNNAMED",
					"--add-opens",
					"java.base/java.lang=ALL-UNNAMED",
					"-jar",
					launcher_jar,
					"-configuration",
					config_dir,
					"-data",
					ws_dir,
				}

				return vim.lsp.rpc.start(cmd, dispatchers, {
					cwd = config.cmd_cwd,
					env = config.cmd_env,
					detached = config.detached,
				})
			end,
			root_dir = function(bufnr, on_dir)
				on_dir(java_root(vim.api.nvim_buf_get_name(bufnr)))
			end,
			filetypes = { "java" },
			settings = {
				java = {
					autobuild = {
						enabled = true, -- Avoid constant rebuilds
					},
					references = {
						includeAccessors = true, -- Important for DTOs!
						includeDecompiledSources = true,
					},
					-- Set to 'automatic' instead of 'interactive'
					-- This ensures that when you change a DTO, the index updates immediately
					configuration = {
						updateBuildConfiguration = "automatic",
					},
					format = { enabled = true },
					saveActions = { organizeImports = true },
				},
			},
		})
		vim.lsp.enable("jdtls")

		-- Find the project root directory.
		-- This looks upwards from the current file for a '.git' directory or an 'angular.json' file.
		local project_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1] or vim.fn.findcwd({ "nx.json" })
		local ngserver_path = project_root .. "/node_modules/.bin/ngserver"
		local node_modules_path = project_root .. "/node_modules"
		vim.lsp.config("angularls", {
			cmd = {
				ngserver_path,
				"--stdio",
				"--tsProbeLocations",
				node_modules_path,
				"--ngProbeLocations",
				node_modules_path,
			},
			-- filetypes = { "typescript", 'htmlangular' },
			-- root_markers = { 'angular.json', 'project.json', 'package.json', '.git' },
		})
		vim.lsp.enable("angularls")
	end,
}
