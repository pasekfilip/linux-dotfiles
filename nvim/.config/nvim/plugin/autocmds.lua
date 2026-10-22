vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight", { clear = true }),
	callback = function()
		vim.hl.hl_op({higroup='Visual', timeout=300})
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "kulala://*",
	callback = function()
		vim.opt_local.buftype = "nofile"
		vim.opt_local.bufhidden = "hide"
		vim.opt_local.swapfile = false
	end,
})

-- Runs on every FileType so it wins over the ftplugins, which each set their
-- own formatoptions.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt.formatoptions = "jql"
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sql", "mysql", "pgsql", "plsql" },
	callback = function()
		vim.bo.commentstring = "-- %s"
		vim.keymap.set("v", "x", ":DB<CR>", { buffer = true, silent = true })
	end,
})
