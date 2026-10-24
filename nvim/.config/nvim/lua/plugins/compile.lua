return {
	"ej-shafran/compile-mode.nvim",
	version = "^5.0.0",
	cmd = { "Compile", "Recompile", "NextError", "PrevError", "FirstError", "QuickfixErrors" },
	-- Output goes in a 12-line strip along the bottom (`botright 12`). To get
	-- rid of it: `q` inside it, or <C-w>o from the code (Emacs C-x 1).
	keys = {
		-- Recompile falls back to the prompt the first time (recompile_no_fail).
		{ "<leader>m", "<cmd>botright 12Recompile<CR>", desc = "Recompile (or compile)" },
		{ "<leader>M", "<cmd>botright 12Compile<CR>", desc = "Compile (prompt for command)" },
	},
	init = function()
		-- Errors go into the quickfix list like Emacs' next-error, so ]q/[q walk
		-- build errors and grep results alike. Only the plugin fires this event,
		-- so the require is safe even though this is registered before it loads.
		vim.api.nvim_create_autocmd("User", {
			pattern = "CompilationFinished",
			callback = function()
				require("compile-mode").send_to_qflist()
			end,
		})

		---@module "compile-mode"
		---@type CompileModeOpts
		vim.g.compile_mode = {
			default_command = {
				["*"] = "make -k ",
				c = "cc -o %:r % && ./%:r",
				cpp = "cmake --build build && ./build/main",
				java = "mvn -q package",
				lua = "lua %",
				odin = "odin run .",
				python = "python %",
				sh = "sh %",
			},
			-- Odin reports `file(row:col) Error:`, which none of the built-in
			-- matchers cover (`msft` is closest but demands a ` : error C1234:`
			-- suffix), so errors would otherwise not be jumpable.
			error_regexp_table = {
				odin = {
					regex = "^\\([^(]\\+\\.odin\\)(\\([0-9]\\+\\):\\([0-9]\\+\\)) \\%(\\(Warning\\)\\|\\(Suggestion\\)\\|\\%(Syntax \\)\\?Error\\):",
					filename = 1,
					row = 2,
					col = 3,
					type = { 4, 5 },
				},
			},
			-- Expand %, %:r etc. like :! does.
			bang_expansion = true,
			-- Land on the first error instead of the end of the output.
			auto_jump_to_first_error = true,
			-- Fall back to :Compile when there's nothing to recompile yet.
			recompile_no_fail = true,
		}
	end,
}
