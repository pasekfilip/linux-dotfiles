local api = vim.api

-- --- JAVA BUILD AND DEPLOY ---
vim.keymap.set("n", "<leader>jb", function()
	-- NOTE: Assumes Tomcat was installed via a package manager like pacman
	local tomcat_webapps_dir = "/usr/share/tomcat9/webapps/"
	local source_war_path = "SignoSoftServer/target/SignoSoftServer.war"
	local dest_war_path = tomcat_webapps_dir .. "api.war"

	local build_cmd = string.format(
		[[mvn clean package -DskipTests && rm -f %s && install -m644 -g tomcat9 %s %s]],
		dest_war_path,
		source_war_path,
		dest_war_path
	)
	print("Running Linux Java build & deploy...")

	-- 1. Create the split
	vim.cmd("botright 10split")
	local term_win = api.nvim_get_current_win()
	local term_buf = api.nvim_create_buf(false, true)
	api.nvim_win_set_buf(term_win, term_buf)

	-- 2. Run the job inside the terminal buffer
	vim.fn.jobstart(build_cmd, {
		term = true, -- Enables terminal colors and behavior
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				-- SUCCESS: Close the terminal window automatically
				if api.nvim_win_is_valid(term_win) then
					api.nvim_win_close(term_win, true)
				end
				vim.notify("🚀 Build & Deploy Successful!", vim.log.levels.INFO)
			else
				-- FAILURE: Leave window open so you can read the error
				vim.notify("❌ Build Failed! Check the terminal below.", vim.log.levels.ERROR)
			end
		end,
	})
	api.nvim_win_set_cursor(term_win, { vim.api.nvim_buf_line_count(term_buf), 0 })
end, { buffer = true, silent = false, desc = "Java build & deploy to Tomcat" }) -- silent=false to see the print messages
