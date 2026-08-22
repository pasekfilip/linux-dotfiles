return {
	"ej-shafran/compile-mode.nvim",
	version = "^5.0.0",
	cmd = { "Compile", "Recompile", "NextError", "PrevError", "FirstError", "QuickfixErrors" },
	keys = {
		{ "<leader>cc", ":Compile ", desc = "Compile (prompt for command)" },
		{ "<leader>cr", "<cmd>Recompile<CR>", desc = "Recompile last command" },
		{ "<leader>cn", "<cmd>NextError<CR>", desc = "Next compile error" },
		{ "<leader>cp", "<cmd>PrevError<CR>", desc = "Prev compile error" },
		{ "<leader>cq", "<cmd>QuickfixErrors<CR>", desc = "Compile errors to quickfix" },
		-- The buffer-local `q` only works while focused in the compilation
		-- window; this closes it from wherever the cursor happens to be.
		{
			"<leader>cx",
			function()
				if vim.g.compilation_buffer then
					require("compile-mode").close_buffer()
				end
			end,
			desc = "Close compilation window",
		},
		-- SignoSoftServer: build the WAR and drop it into Tomcat. Routed through
		-- compile-mode so mvn's `[ERROR] File.java:[row,col]` lines are jumpable
		-- and <leader>cr re-runs the whole thing. The relative WAR path means cwd
		-- must be the repo root, same as the old <leader>jb.
		{
			"<leader>cd",
			function()
				local war = "/usr/share/tomcat9/webapps/api.war"
				require("compile-mode").compile({
					args = table.concat({
						-- -B: batch mode, so no ANSI codes or download-progress
						-- spam in a buffer that isn't a terminal.
						"mvn -B clean package -DskipTests",
						"rm -f " .. war,
						"install -m644 -g tomcat9 SignoSoftServer/target/SignoSoftServer.war " .. war,
					}, " && "),
				})
			end,
			desc = "Build WAR & deploy to Tomcat",
		},
	},
	init = function()
		---@module "compile-mode"
		---@type CompileModeOpts
		vim.g.compile_mode = {
			default_command = {
				["*"] = "make -k ",
				c = "cc -o %:r % && ./%:r",
				cpp = "cmake --build build && ./build/main",
				java = "mvn -q compile",
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
			-- blink.cmp otherwise eats <Tab> completion in the :Compile prompt.
			input_word_completion = true,
			-- Land on the first error instead of the end of the output.
			auto_jump_to_first_error = true,
			-- Fall back to :Compile when there's nothing to recompile yet.
			recompile_no_fail = true,
		}

		-- compile-mode maps <C-w>f buffer-locally (open the error's file in a
		-- split). That makes our global <C-w> -> :q sit through `timeoutlen`
		-- waiting for an `f` before it fires. Drop it so <C-w> closes the
		-- compilation window instantly, like it does everywhere else.
		-- Scheduled because the plugin's ftplugin sets the map on this same
		-- FileType event, and we have to land after it.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "compilation",
			desc = "Let <C-w> close the compilation window without a timeout",
			callback = function(ev)
				vim.schedule(function()
					pcall(vim.keymap.del, "n", "<C-w>f", { buffer = ev.buf })
				end)
			end,
		})
	end,
}
