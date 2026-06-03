local M = {}

local api = vim.api
local set = vim.keymap.set

local state = {
	win = nil,
	current = 1,
}

local list = {
	{ name = "work", path = "/home/filip/work-notes/tasks.md" },
	{ name = "home", path = "/home/filip/notes/tasks.md" },
}

local height = 20
local width = 70

local function get_buf(index)
	local path = list[index].path
	local buf = vim.fn.bufadd(path)
	vim.fn.bufload(buf)
	return buf
end

local function save_buf(buf)
	if api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
		api.nvim_buf_call(buf, function()
			vim.cmd("silent write")
		end)
	end
end

local function close()
	if state.win and api.nvim_win_is_valid(state.win) then
		save_buf(api.nvim_win_get_buf(state.win))
		api.nvim_win_close(state.win, false)
	end
	state.win = nil
end

local function update_title()
	if not (state.win and api.nvim_win_is_valid(state.win)) then
		return
	end

	api.nvim_win_set_config(state.win, {
		title = " Tasks: " .. list[state.current].name .. " ",
		title_pos = "center",
	})
end

local swap

local function setup_keymaps(buf)
	set("n", "<Esc>", close, { buffer = buf, noremap = true, silent = true })
	set("n", "q", close, { buffer = buf, noremap = true, silent = true })
	set("n", "<leader>i", close, { buffer = buf, noremap = true, silent = true })
	set("n", "<Tab>", swap, { buffer = buf, noremap = true, silent = true })
end

swap = function()
	if not (state.win and api.nvim_win_is_valid(state.win)) then
		return
	end

	save_buf(api.nvim_win_get_buf(state.win))
	state.current = state.current % #list + 1

	local buf = get_buf(state.current)
	api.nvim_win_set_buf(state.win, buf)
	setup_keymaps(buf)
	update_title()
end

function M.toggle()
	if state.win and api.nvim_win_is_valid(state.win) then
		close()
		return
	end

	local buf = get_buf(state.current)
	local centeredHeight = math.floor((vim.o.lines - height) / 2)
	local centeredWidth = math.floor((vim.o.columns - width) / 2)

	state.win = api.nvim_open_win(buf, true, {
		relative = "editor",
		row = centeredHeight,
		col = centeredWidth,
		height = height,
		width = width,
		border = "single",
		title = " Tasks: " .. list[state.current].name .. " ",
		title_pos = "center",
	})

	setup_keymaps(buf)
end

return M
