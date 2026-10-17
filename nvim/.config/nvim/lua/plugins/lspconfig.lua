return {
	"neovim/nvim-lspconfig",
	enabled = vim.g.lsp, -- see init.lua
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
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "User lsp formatter"
				keymap.set("n", "<leader>lf", vim.lsp.buf.format, opts)

				opts.desc = "Show signature help"
				keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts)
			end,
		})

		vim.diagnostic.config({
			underline = true,
			virtual_text = false,
			virtual_lines = false,
			-- The sign column is kept for DAP breakpoints only (signcolumn=auto
			-- in plugin/options.lua); diagnostics show as underlines, in the
			-- lualine counts, and via ]d / <leader>ld.
			signs = false,
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

		keymap.set("n", "<leader>ld", function()
			vim.diagnostic.open_float(nil, { scope = "line", focus = true })
		end, { desc = "Show line diagnostics" })

		vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

		-- Per-server settings are in after/lsp/<name>.lua.
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

		vim.lsp.enable("angularls")
	end,
}
