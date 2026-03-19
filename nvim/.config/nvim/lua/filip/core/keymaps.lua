vim.g.mapleader = " "
local set = vim.keymap.set
local del = vim.keymap.del

set("n", "<C-s>", ":w<CR>", { desc = "Save file", noremap = true, silent = true })
set("i", "<C-s>", "<cmd>:w<CR>", { desc = "Save file", noremap = true, silent = true })

-- window management
del("n", "<C-w>d")
del("n", "<C-W><C-D>")
set("n", "<C-w>", "<cmd>:q<CR>", { desc = "Close current window" })
set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
set("n", "<leader>sq", "<cmd>close<CR>", { desc = "Close current split" })
set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search with esc" })

set("n", "<C-Left>", "<cmd>vertical resize -5<CR>", { desc = "Make the window smaller by 5 columns" })
set("n", "<C-Right>", "<cmd>vertical resize +5<CR>", { desc = "Make the window bigger by 5 columns" })
set("n", "<C-up>", "<cmd>resize +5<CR>", { noremap = true, silent = true })
set("n", "<C-down>", "<cmd>resize -5<CR>", { noremap = true, silent = true })

set("n", "<C-a>", "ggVG", { desc = "select all everything inside current file" })

set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Go into the normal mode in terminal mode" })

set("v", "J", ":m '>+1<CR>gv=gv")
set("v", "K", ":m '<-2<CR>gv=gv")

set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")

set("n", "n", "nzzzv")
set("n", "N", "Nzzzv")

set("x", ">", ">gv")
set("x", "<", "<gv")

set("x", "<leader>p", '"_dP', { desc = "When pasting over selected it sends it to the void register" })

-- Copy Full File-Path
set("n", "<leader>yp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end)

set("n", "<leader>jb", function()
	-- --- JAVA BUILD AND DEPLOY ---
	if vim.bo.filetype == "java" then
		-- NOTE: Assumes Tomcat was installed via a package manager like pacman
		local tomcat_webapps_dir = "/usr/share/tomcat9/webapps/"
		local source_war_path = "SignoSoftServer/target/SignoSoftServer.war"
		local dest_war_path = tomcat_webapps_dir .. "api.war"

		local build_cmd = string.format(
			[[mvn clean package -DskipTests && rm -f %s && cp %s %s]],
			dest_war_path,
			source_war_path,
			dest_war_path
		)
		print("Running Linux Java build & deploy...")

		local main_win = vim.api.nvim_get_current_win()

		-- 1. Create the split
		vim.cmd("botright 10split")
		local term_win = vim.api.nvim_get_current_win()
		local term_buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_win_set_buf(term_win, term_buf)

		-- 2. Run the job inside the terminal buffer
		vim.fn.jobstart(build_cmd, {
			term = true, -- Enables terminal colors and behavior
			on_exit = function(_, exit_code)
				if exit_code == 0 then
					-- SUCCESS: Close the terminal window automatically
					if vim.api.nvim_win_is_valid(term_win) then
						vim.api.nvim_win_close(term_win, true)
					end
					vim.notify("🚀 Build & Deploy Successful!", vim.log.levels.INFO)
				else
					-- FAILURE: Leave window open so you can read the error
					vim.notify("❌ Build Failed! Check the terminal below.", vim.log.levels.ERROR)
				end
			end,
		})

		-- 3. FOLLOW THE PRINT (Auto-scroll)
		-- To auto-scroll, the cursor must be on the last line of the terminal
		vim.api.nvim_win_set_cursor(term_win, { vim.api.nvim_buf_line_count(term_buf), 0 })
		-- -- 4. Jump back to your code
		-- vim.api.nvim_set_current_win(main_win)
	end

	-- --- C++ BUILD AND RUN ---
	if vim.bo.filetype == "cpp" then
		local cmd
		local build_dir = vim.fs.joinpath(vim.fn.getcwd(), "build")

		if vim.fn.has("unix") == 1 then
			-- On Linux, the executable usually has no extension
			cmd = string.format("cd %s && cmake --build . && ./main", build_dir)
			print("Running Linux C++ build...")
		elseif vim.fn.has("win32") == 1 then
			-- On Windows, it has .exe
			cmd = string.format([[cd %s && cmake --build . && main.exe]], build_dir)
			print("Running Windows C++ build...")
		end

		if cmd then
			vim.cmd("!" .. cmd)
		end
	end
end, { noremap = true, silent = false }) -- Set silent=false to see the print messages

-- set("n", "<F5>", function()
-- 	if vim.bo.filetype == "cpp" then
-- 		vim.cmd("!cd " .. vim.fn.getcwd() .. "\\build && cmake --build . && main.exe")
-- 	end
-- end, { noremap = true, silent = true })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sql", "mysql", "pgsql", "plsql" },
	callback = function()
		vim.bo.commentstring = "-- %s"
		set("v", "x", ":DB<CR>", { buffer = true, silent = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		set("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line", buffer = true, silent = true })
		set(
			"n",
			"<leader><leader>x",
			"<cmd>source %<CR>",
			{ desc = "Execute the current file", buffer = true, silent = true }
		)
	end,
})
-- very cool remap
set("n", "j", function()
	local count = vim.v.count

	if count == 0 then
		return "gj"
	else
		return "j"
	end
end, { expr = true })

set("n", "k", function()
	local count = vim.v.count

	if count == 0 then
		return "gk"
	else
		return "k"
	end
end, { expr = true })
