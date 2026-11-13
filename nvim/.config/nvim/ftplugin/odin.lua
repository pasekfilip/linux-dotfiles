-- Tags-based navigation for Odin, no LSP.
-- Needs universal-ctags (pacman: ctags) and ~/.config/ctags/odin.ctags, which
-- teaches ctags what an Odin file is.
--
--   gd           jump to the definition of the word under the cursor (<C-t> back)
--   :OdinTags    build ./tags for the project in the current directory
--   :OdinTags!   same, and rebuild the stdlib tags (do this after upgrading Odin)
--
-- A project is opted in by having a tags file: once one exists at or above an
-- Odin file, saving that file regenerates it.

local stdlib_tags = vim.fn.stdpath("cache") .. "/odin-stdlib-tags"
local running = {}

-- Run ctags into `out`, one run per output file at a time.
local function ctags(out, inputs, cwd, on_done)
	if running[out] then
		return
	end
	running[out] = true
	local cmd = { "ctags", "--languages=Odin", "-R", "-f", out }
	vim.list_extend(cmd, inputs)
	vim.system(cmd, { cwd = cwd, text = true }, function(res)
		running[out] = nil
		vim.schedule(function()
			if res.code ~= 0 then
				vim.notify("ctags failed: " .. (res.stderr or ""), vim.log.levels.ERROR)
			elseif on_done then
				on_done()
			end
		end)
	end)
end

local function build_stdlib(on_done)
	local root = vim.trim(vim.fn.system({ "odin", "root" }))
	if vim.v.shell_error ~= 0 or root == "" then
		return
	end
	local inputs = {}
	for _, collection in ipairs({ "base", "core", "vendor" }) do
		local dir = vim.fs.joinpath(root, collection)
		if vim.uv.fs_stat(dir) then
			inputs[#inputs + 1] = dir
		end
	end
	-- Absolute inputs give absolute paths in the tags file, so it can live
	-- outside the root-owned source tree it indexes.
	ctags(stdlib_tags, inputs, nil, on_done)
end

local has_ctags = vim.fn.executable("ctags") == 1

vim.opt_local.tags:append(stdlib_tags)

if has_ctags and not vim.uv.fs_stat(stdlib_tags) then
	build_stdlib()
end

vim.keymap.set("n", "gd", function()
	-- :tjump jumps straight there for one match and lists them for several.
	-- No tag (a local, a parameter): fall back to the built-in text search.
	if not pcall(vim.cmd.tjump, vim.fn.expand("<cword>")) then
		vim.cmd("normal! gd")
	end
end, { buffer = true, desc = "Go to definition (tags)" })

vim.api.nvim_buf_create_user_command(0, "OdinTags", function(opts)
	if not has_ctags then
		vim.notify("ctags is not installed", vim.log.levels.ERROR)
		return
	end
	local cwd = vim.fn.getcwd()
	ctags("tags", {}, cwd, function()
		vim.notify("Built " .. vim.fs.joinpath(cwd, "tags"))
	end)
	if opts.bang then
		build_stdlib(function()
			vim.notify("Built " .. stdlib_tags)
		end)
	end
end, { bang = true, desc = "Build Odin tags for the current directory" })

local group = vim.api.nvim_create_augroup("odin_tags", { clear = false })
vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	buffer = 0,
	desc = "Regenerate the project's tags file, if it has one",
	callback = function(ev)
		if not has_ctags then
			return
		end
		local found = vim.fs.find("tags", {
			upward = true,
			type = "file",
			path = vim.fs.dirname(vim.api.nvim_buf_get_name(ev.buf)),
			stop = vim.env.HOME,
		})[1]
		if found then
			ctags("tags", {}, vim.fs.dirname(found))
		end
	end,
})
