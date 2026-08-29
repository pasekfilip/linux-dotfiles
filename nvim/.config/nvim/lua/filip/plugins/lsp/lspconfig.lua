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
				keymap.set("n", "gR", "<cmd>FzfLua lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", vim.lsp.buf.implementation, opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>FzfLua lsp_typedefs<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>FzfLua diagnostics_document<CR>", opts) -- show  diagnostics for file

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

		local mason = vim.fn.stdpath("data") .. "/mason"

		-- java-debug-adapter bundle (installed via Mason or auto-installed in debug.lua)
		local debug_jar = vim.fn.glob(
			mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
			true
		)
		local bundles = {}
		if debug_jar ~= "" then
			table.insert(bundles, debug_jar)
		end

		-- What used to be hand-rolled here -- locating the equinox launcher and
		-- config_linux, naming a workspace per project root, and a root_dir preferring the
		-- reactor over a submodule -- is exactly what lspconfig's own lsp/jdtls.lua does,
		-- using the same markers in the same order. It runs mason's `jdtls` wrapper, which
		-- also supplies the eclipse -D flags, --add-modules=ALL-SYSTEM and both
		-- --add-opens pairs. The one thing neither can guess is JVM tuning, read from this
		-- env var: each space-separated token becomes one --jvm-arg=, so every flag must
		-- be a single token (hence `--add-opens=a=b` form, if you ever add one).
		vim.env.PATH = mason .. "/bin:" .. vim.env.PATH
		vim.env.JDTLS_JVM_ARGS = table.concat({
			"-javaagent:" .. mason .. "/packages/jdtls/lombok.jar",
			"-Xmx4g",
			"-XX:+UseG1GC",
			"-XX:+UseStringDeduplication",
			"-Dlog.level=ERROR",
		}, " ")

		vim.lsp.config("jdtls", {
			init_options = {
				bundles = bundles, -- enables vscode.java.startDebugSession command
				-- jdtls will not answer a definition request with a class-file location
				-- unless the client says it can render one -- it returns an empty result
				-- instead of a jdt:// URI. lspconfig never advertises this (its
				-- init_options is `{}`), which is why `gd` did nothing on anything from a
				-- jar while project sources jumped fine. The BufReadCmd below is the other
				-- half: it fetches the content the URI points at.
				extendedClientCapabilities = {
					classFileContentsSupport = true,
				},
			},
			settings = {
				java = {
					autobuild = {
						-- Eclipse runs an incremental build on every buffer change when this
						-- is on, which pegs the JVM while you're just moving around the file.
						-- Off means cross-file diagnostics refresh on save instead.
						enabled = false,
					},
					references = {
						includeAccessors = true, -- Important for DTOs!
						-- Was false to stop `gR` scanning every JAR index. The hidden cost was
						-- that `gd` did nothing at all on a type from a jar: with no source
						-- attached and decompiling off, there is no document to open. Measured
						-- with a definition request -- ArrayList and StringUtils both returned
						-- no result, while a project class resolved fine.
						includeDecompiledSources = true,
					},
					-- 'automatic' re-imports the whole Maven/Gradle model on any pom or
					-- build-file change, which is a multi-second full-CPU stall. 'interactive'
					-- prompts instead; accept it (or :LspRestart) after editing a pom.
					configuration = {
						updateBuildConfiguration = "interactive",
						-- Without this the only VM Eclipse knows about is the one jdtls itself
						-- runs on (default-runtime -> 21). This project targets 11, so the
						-- JavaSE-11 execution environment in every module's .classpath had no
						-- matching install and therefore no source attachment: java.* types
						-- resolved via ct.sym (hence no errors) but `gd` had nowhere to go.
						-- Each of these ships its own lib/src.zip.
						runtimes = {
							{ name = "JavaSE-11", path = "/usr/lib/jvm/java-11-amazon-corretto" },
							{ name = "JavaSE-17", path = "/usr/lib/jvm/java-17-amazon-corretto" },
							{ name = "JavaSE-21", path = "/usr/lib/jvm/java-21-amazon-corretto", default = true },
						},
					},
					format = { enabled = true },
					saveActions = { organizeImports = true },
				},
			},
		})
		vim.lsp.enable("jdtls")

		-- Second half of classFileContentsSupport. jdtls now answers `gd` on a library
		-- type with a `jdt://` URI, but nvim has no idea how to read that scheme, so the
		-- jump would land in an empty buffer. jdtls serves the attached source (or a
		-- decompilation, when no sources jar exists) through this custom request.
		vim.api.nvim_create_autocmd("BufReadCmd", {
			group = vim.api.nvim_create_augroup("JdtlsClassFile", { clear = true }),
			pattern = "jdt://*",
			callback = function(ev)
				local client = vim.lsp.get_clients({ name = "jdtls" })[1]
				if not client then
					return
				end
				local res = client:request_sync("java/classFileContents", { uri = ev.match }, 5000, ev.buf)
				local text = (res and not res.err and res.result) or "// jdtls returned no content"

				vim.bo[ev.buf].modifiable = true
				vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, vim.split(text, "\n", { plain = true }))
				vim.bo[ev.buf].filetype = "java"
				vim.bo[ev.buf].buftype = "nofile"
				vim.bo[ev.buf].modifiable = false
				vim.bo[ev.buf].modified = false
			end,
		})

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
