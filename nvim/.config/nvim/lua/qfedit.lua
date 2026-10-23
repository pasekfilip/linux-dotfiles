-- Editable quickfix, like wgrep in Emacs: open() dumps every quickfix line
-- into a buffer as "file:lnum: text", you edit the text part, :w writes the
-- changed lines back to their files. Don't add, delete or reorder lines.
local M = {}

local api = vim.api
local name = "qfedit://"

local function write(buf, entries)
	local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
	if #lines ~= #entries then
		vim.notify("qfedit: line count changed, nothing written", vim.log.levels.ERROR)
		return
	end

	local touched = {}
	local changed = 0
	for i, e in ipairs(entries) do
		if not vim.startswith(lines[i], e.prefix) then
			vim.notify("qfedit: prefix edited on line " .. i .. ", nothing written", vim.log.levels.ERROR)
			return
		end
	end

	for i, e in ipairs(entries) do
		local new = lines[i]:sub(#e.prefix + 1)
		if new ~= e.text then
			local current = api.nvim_buf_get_lines(e.bufnr, e.lnum - 1, e.lnum, false)[1]
			if current ~= e.text then
				vim.notify("qfedit: " .. e.prefix .. " changed on disk, skipped", vim.log.levels.WARN)
			else
				api.nvim_buf_set_lines(e.bufnr, e.lnum - 1, e.lnum, false, { new })
				e.text = new
				touched[e.bufnr] = true
				changed = changed + 1
			end
		end
	end

	for b in pairs(touched) do
		api.nvim_buf_call(b, function()
			vim.cmd("silent update")
		end)
	end

	vim.bo[buf].modified = false
	vim.notify("qfedit: " .. changed .. " line(s) written")
end

function M.open()
	local entries, lines, seen = {}, {}, {}
	for _, it in ipairs(vim.fn.getqflist()) do
		local key = it.bufnr .. ":" .. it.lnum
		-- several matches on one line give several qf items, keep only one
		if it.valid == 1 and it.bufnr > 0 and it.lnum > 0 and not seen[key] then
			seen[key] = true
			vim.fn.bufload(it.bufnr)
			-- read the real line, the qf text can be trimmed
			local text = api.nvim_buf_get_lines(it.bufnr, it.lnum - 1, it.lnum, false)[1]
			if text then
				local file = vim.fn.fnamemodify(api.nvim_buf_get_name(it.bufnr), ":.")
				local prefix = file .. ":" .. it.lnum .. ": "
				table.insert(entries, { bufnr = it.bufnr, lnum = it.lnum, text = text, prefix = prefix })
				table.insert(lines, prefix .. text)
			end
		end
	end

	if #entries == 0 then
		vim.notify("qfedit: quickfix is empty", vim.log.levels.WARN)
		return
	end

	local old = vim.fn.bufnr(name)
	if old ~= -1 then
		api.nvim_buf_delete(old, { force = true })
	end

	local buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_name(buf, name)
	vim.bo[buf].buftype = "acwrite"
	vim.bo[buf].bufhidden = "wipe"
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modified = false

	api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			write(buf, entries)
		end,
	})

	if vim.bo.buftype == "quickfix" then
		vim.cmd("wincmd p")
	end
	api.nvim_win_set_buf(0, buf)
end

-- like M-x grep: ask for a pattern (word under cursor by default), grep
-- whole words into quickfix and open the edit buffer straight away
function M.grep()
	vim.ui.input({ prompt = "grep: ", default = vim.fn.expand("<cword>") }, function(pattern)
		if not pattern or pattern == "" then
			return
		end
		-- escape % and # so :grep doesn't expand them to file names
		pcall(vim.cmd, "silent grep! -w " .. vim.fn.escape(vim.fn.shellescape(pattern), "%#"))
		M.open()
	end)
end

return M
