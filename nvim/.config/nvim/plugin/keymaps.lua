-- mapleader is set in init.lua: it has to be in place before lazy.setup().
local set = vim.keymap.set
local api = vim.api

set("n", "<C-s>", ":w<CR>", { desc = "Save file", noremap = true, silent = true })
set("i", "<C-s>", "<cmd>:w<CR>", { desc = "Save file", noremap = true, silent = true })

-- window management. <C-w> is left to vim: <C-w>o only this window (Emacs
-- C-x 1), <C-w>c close this one (C-x 0), <C-w>w next window (C-x o).
set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
set("n", "<C-h>", "<C-w>h")
set("n", "<C-j>", "<C-w>j")
set("n", "<C-k>", "<C-w>k")
set("n", "<C-l>", "<C-w>l")

local function resize(direction, vertical)
	vertical = vertical or ""
	local current_window_num = vim.fn.winnr()
	local count_left = vim.fn.winnr(direction)

	if count_left == current_window_num then
		vim.cmd(vertical .. " resize -2")
	else
		vim.cmd(vertical .. " resize +2")
	end
end

set("n", "<C-left>", function()
	resize("1h", "vertical")
end)

set("n", "<C-right>", function()
	resize("1l", "vertical")
end)

set("n", "<C-up>", function()
	resize("1k")
end)

set("n", "<C-down>", function()
	resize("1j")
end)

set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search with esc" })
set("t", "<Esc>", "<C-\\><C-n>", { desc = "Go into the normal mode in terminal mode" })

set("v", "J", ":m '>+1<CR>gv=gv")
set("v", "K", ":m '<-2<CR>gv=gv")

set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")

set("n", "n", "nzzzv")
set("n", "N", "Nzzzv")

set("x", ">", ">gv")
set("x", "<", "<gv")

set("x", "<leader>p", '"_dP', { desc = "When pasting over selected it sends it to the void register" })

set("n", "<leader>i", function()
	require("task").toggle()
end)

-- Copy Full File-Path
set("n", "<leader>yp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end)

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

set("n", "<leader>u", function()
	for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
		if vim.bo[api.nvim_win_get_buf(win)].filetype == "nvim-undotree" then
			api.nvim_win_close(win, true)
			return
		end
	end
	vim.cmd.packadd("nvim.undotree")
	require("undotree").open()
end, { desc = "Toggle undo tree" })
