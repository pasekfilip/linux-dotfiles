-- Async :make. The command runs in the background and every output line goes
-- straight into a quickfix list, so the quickfix window *is* the compilation
-- buffer: lines vim's 'errorformat' recognises become jumpable entries, the
-- current one is highlighted (QuickFixLine) and :cnext/]q move the cursor in
-- that window along with you. The window shows the output exactly as the
-- compiler printed it (no `file|lnum|` columns), coloured like compile-mode.
local M = {}

local api = vim.api

-- Used when there's no previous command to offer. A buffer can override it
-- with vim.b.compile_command (ftplugin, exrc, or by hand). %, %:r etc. are
-- expanded like :! does, against the buffer you compile from.
local commands = {
	["*"] = "make -k",
	c = "cc -o %:r % && ./%:r",
	cpp = "cmake --build build && ./build/main",
	java = "mvn -q package",
	lua = "lua %",
	odin = "odin run % -file",
	python = "python %",
	sh = "sh %",
}

-- Tried before the global 'errorformat' (which already covers gcc/clang/make)
-- for compilers vim doesn't understand out of the box. Lines are parsed one at
-- a time, so multi-line formats (%A/%C/%Z) and make's directory tracking
-- (%D/%X) don't work here.
local errorformats = {
	odin = "%f(%l:%c) %m",
	java = "[ERROR] %f:[%l\\,%c] %m",
	python = '%*\\sFile "%f"\\, line %l%.%#',
	lua = "%*[^:]: %f:%l: %m",
}

-- Where the window opens: `<position> copen <size>`. For a split on the right
-- use { position = "vertical botright", size = 80 }.
local window = { position = "botright", size = 8 }

local ns = api.nvim_create_namespace("compile")

local state = {
	cmd = nil,
	cwd = nil,
	efm = nil,
	job = nil,
	qf_id = nil,
	-- Identifies the current run, so output from a killed job that is still
	-- queued in vim.schedule doesn't end up in the new list.
	token = nil,
}

local function open_window()
	local win = api.nvim_get_current_win()
	vim.cmd(window.position .. " copen " .. window.size)
	if api.nvim_win_is_valid(win) then
		api.nvim_set_current_win(win)
	end
end

local function is_current_list(id)
	return vim.fn.getqflist({ id = 0 }).id == id
end

-- 'quickfixtextfunc' for our lists: show each line as it was printed. An
-- empty string would make vim fall back to its own `||` formatting, so blank
-- lines become a space.
local function textfunc(info)
	local items = vim.fn.getqflist({ id = info.id, items = 0 }).items
	local out = {}
	for i = info.start_idx, info.end_idx do
		local text = items[i].text
		table.insert(out, text == "" and " " or text)
	end
	return out
end

-- Parse line by line so every entry keeps the compiler's exact text: vim's
-- parser would cut an error down to its message and drop the lines the
-- 'errorformat' tells it to ignore (%-G).
local function to_items(lines, efm)
	local items = {}
	for _, line in ipairs(lines) do
		local item = vim.fn.getqflist({ lines = { line }, efm = efm }).items[1]
		if not (item and item.valid == 1) then
			item = { valid = 0 }
		end
		item.text = line
		table.insert(items, item)
	end
	return items
end

-- Start and end of `file:line:col` (or `file(line:col)`, `file:[line,col]`,
-- ...) in an error line: from the file name back to the whitespace or quote
-- before it, then forward over the numbers and punctuation after it.
local function location(line, item)
	local name = vim.fn.fnamemodify(vim.fn.bufname(item.bufnr), ":t")
	local s = name ~= "" and line:find(name, 1, true)
	if not s then
		return nil
	end
	local e = s + #name - 1
	while s > 1 and not line:sub(s - 1, s - 1):match("[%s\"'%[]") do
		s = s - 1
	end
	while line:sub(e + 1, e + 1):match("[%d:(),%[%]]") do
		e = e + 1
	end
	return s, e
end

local keywords = {
	{ "error", "DiagnosticError" },
	{ "warning", "DiagnosticWarn" },
	{ "note", "DiagnosticInfo" },
}

local kinds = {
	meta = "Comment",
	cmd = "Title",
	ok = "DiagnosticOk",
	fail = "DiagnosticError",
}

local function hl(buf, row, s, e, group)
	api.nvim_buf_set_extmark(buf, ns, row, s, { end_col = e, hl_group = group })
end

-- Colour the quickfix window from line `first` on, if it shows our list.
-- Other lists (:grep, :make) keep the stock qf syntax, which we have to turn
-- off for ours: it reads everything before a `|` as a file name, so our raw
-- lines would come out as one long file name.
local function paint(first)
	local info = vim.fn.getqflist({ id = 0, qfbufnr = 0, items = 0 })
	local buf = info.qfbufnr
	if buf == 0 or not api.nvim_buf_is_loaded(buf) then
		return
	end
	if info.id ~= state.qf_id then
		api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		if vim.bo[buf].syntax == "" then
			vim.bo[buf].syntax = "qf"
		end
		return
	end
	vim.bo[buf].syntax = ""

	first = first or 1
	api.nvim_buf_clear_namespace(buf, ns, first - 1, -1)
	local lines = api.nvim_buf_get_lines(buf, first - 1, -1, false)
	for i, line in ipairs(lines) do
		local row = first + i - 2
		local item = info.items[row + 1]
		if not item then
			break
		end
		if kinds[item.user_data] then
			hl(buf, row, 0, #line, kinds[item.user_data])
		elseif item.valid == 1 then
			local s, e = location(line, item)
			if s then
				hl(buf, row, s - 1, e, "Directory")
			end
			local lower = line:lower()
			for _, kw in ipairs(keywords) do
				local ks, ke = lower:find("%f[%a]" .. kw[1] .. "%f[%A]", e or 1)
				if ks then
					hl(buf, row, ks - 1, ke, kw[2])
					break
				end
			end
		end
	end
end

local function meta(text, kind)
	return { text = text, valid = 0, user_data = kind or "meta" }
end

-- vim.system hands output over in arbitrary chunks; glue them back into whole
-- lines and keep the unfinished tail for the next chunk.
local function line_reader(on_lines)
	local partial = ""
	return function(_, data)
		if not data then
			if partial ~= "" then
				on_lines({ partial })
			end
			partial = ""
			return
		end
		local lines = vim.split(partial .. data, "\n", { plain = true })
		partial = table.remove(lines)
		if #lines > 0 then
			on_lines(lines)
		end
	end
end

local function run(cmd, cwd, efm)
	if state.job then
		state.job:kill("sigterm")
	end

	local token = {}
	state.token = token

	-- Create the list empty first: items passed in the same call get rendered
	-- before the list's own textfunc applies, i.e. by the global one
	-- (quicker.nvim), whose delayed extmarks then hit our lines.
	vim.fn.setqflist({}, " ", { title = cmd, quickfixtextfunc = textfunc })
	local id = vim.fn.getqflist({ id = 0 }).id
	vim.fn.setqflist({}, "a", {
		id = id,
		items = {
			meta(string.format('-*- mode: compilation; default-directory: "%s" -*-', vim.fn.fnamemodify(cwd, ":~"))),
			meta("Compilation started at " .. os.date("%a %b %d %H:%M:%S")),
			meta(""),
			meta(cmd, "cmd"),
		},
	})
	state.qf_id = id
	open_window()
	paint()

	local jumped = false
	local start = vim.uv.hrtime()

	local function add(items)
		local before = vim.fn.getqflist({ id = id, size = 0 }).size
		vim.fn.setqflist({}, "a", { id = id, items = items })
		if not is_current_list(id) then
			return
		end
		paint(before + 1)

		if not jumped then
			for i, item in ipairs(items) do
				if item.valid == 1 then
					jumped = true
					pcall(vim.cmd.cc, before + i)
					return
				end
			end
			-- Follow the output until the first error; after that the window
			-- stays on it.
			vim.cmd.cbottom()
		end
	end

	local on_lines = vim.schedule_wrap(function(lines)
		if state.token == token then
			add(to_items(lines, efm))
		end
	end)

	state.job = vim.system({ vim.o.shell, vim.o.shellcmdflag, cmd }, {
		cwd = cwd,
		text = true,
		stdout = line_reader(on_lines),
		stderr = line_reader(on_lines),
	}, vim.schedule_wrap(function(obj)
		if state.token ~= token then
			return
		end
		state.job = nil

		local msg
		if obj.signal ~= 0 then
			msg = "Compilation terminated"
		elseif obj.code == 0 then
			msg = "Compilation finished"
		else
			msg = "Compilation exited abnormally with code " .. obj.code
		end
		local elapsed = (vim.uv.hrtime() - start) / 1e9
		add({
			meta(""),
			meta(
				string.format("%s at %s, duration %.2f s", msg, os.date("%a %b %d %H:%M:%S"), elapsed),
				obj.code == 0 and "ok" or "fail"
			),
		})
		vim.notify(msg)
	end))
end

-- Expand %/# and their :p/:r/:h... modifiers like :! does. Not
-- vim.fn.expandcmd: that also expands $vars, which belong to the shell.
-- \% and \# stay literal.
local function expand(cmd)
	local out, i = {}, 1
	while true do
		local s = cmd:find("[%%#]", i)
		if not s then
			break
		end
		local e = s
		while cmd:sub(e + 1, e + 2):match("^:[phtre~.]$") do
			e = e + 2
		end
		if cmd:sub(s - 1, s - 1) == "\\" then
			table.insert(out, cmd:sub(i, s - 2) .. cmd:sub(s, e))
		else
			table.insert(out, cmd:sub(i, s - 1) .. vim.fn.expand(cmd:sub(s, e)))
		end
		i = e + 1
	end
	table.insert(out, cmd:sub(i))
	return table.concat(out)
end

local function efm_for(ft)
	local extra = errorformats[ft]
	return extra and (extra .. "," .. vim.o.errorformat) or vim.o.errorformat
end

-- Prompt for a command (prefilled with the last one, or this buffer's
-- default) and run it.
function M.compile()
	local ft = vim.bo.filetype
	local default = state.cmd or vim.b.compile_command or commands[ft] or commands["*"]

	vim.ui.input({ prompt = "Compile: ", default = default, completion = "shellcmdline" }, function(input)
		if not input or input == "" then
			return
		end
		state.cmd = expand(input)
		state.cwd = vim.fn.getcwd()
		state.efm = efm_for(ft)
		run(state.cmd, state.cwd, state.efm)
	end)
end

-- Rerun the last command where it ran last time; prompt if there is none.
function M.recompile()
	if not state.cmd then
		M.compile()
		return
	end
	run(state.cmd, state.cwd, state.efm)
end

function M.kill()
	if state.job then
		state.job:kill("sigterm")
	end
end

-- Add or replace per-filetype commands and errorformats, or move the window:
--   require("compile").setup({
--     commands = { zig = "zig build run" },
--     errorformats = { ... },
--     window = { position = "vertical botright", size = 80 },
--   })
function M.setup(opts)
	commands = vim.tbl_extend("force", commands, opts.commands or {})
	errorformats = vim.tbl_extend("force", errorformats, opts.errorformats or {})
	window = vim.tbl_extend("force", window, opts.window or {})
end

-- The quickfix buffer is refilled (and loses its colours) whenever the window
-- reopens, and :grep and friends put a different list in it.
local group = api.nvim_create_augroup("compile", { clear = true })
api.nvim_create_autocmd("BufWinEnter", {
	group = group,
	callback = function(args)
		if vim.bo[args.buf].buftype == "quickfix" then
			vim.schedule(paint)
		end
	end,
})
api.nvim_create_autocmd("QuickFixCmdPost", {
	group = group,
	callback = function()
		vim.schedule(paint)
	end,
})

return M
