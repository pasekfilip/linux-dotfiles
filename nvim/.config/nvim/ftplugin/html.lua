-- Snippets in the plain <C-n> menu: an "F" source in 'complete' feeds our items
-- into the menu, and CompleteDone swaps the inserted trigger for the expanded
-- snippet (vim.snippet, built in; <Tab>/<S-Tab> jump between $1, $2, ... $0).
local snippets = {
	["!"] = table.concat({
		"<!DOCTYPE html>",
		'<html lang="${1:en}">',
		"<head>",
		'\t<meta charset="UTF-8">',
		'\t<meta name="viewport" content="width=device-width, initial-scale=1.0">',
		"\t<title>${2:Document}</title>",
		"</head>",
		"<body>",
		"\t$0",
		"</body>",
		"</html>",
	}, "\n"),
}

-- 'completefunc' protocol: first call (findstart=1) returns the column where
-- the text to replace starts; second call returns the matching items.
function _G.HtmlSnippetComplete(findstart, base)
	if findstart == 1 then
		local col = vim.fn.col(".") - 1
		local before = vim.api.nvim_get_current_line():sub(1, col)
		return col - #before:match("%S*$")
	end
	local items = {}
	for trigger, body in pairs(snippets) do
		if vim.startswith(trigger, base) then
			table.insert(items, {
				word = trigger,
				kind = "Snippet",
				menu = "[html]",
				info = body,
				user_data = { html_snippet = trigger },
			})
		end
	end
	return items
end

vim.bo.completefunc = "v:lua.HtmlSnippetComplete"
vim.opt_local.complete:prepend("F")

vim.api.nvim_create_autocmd("CompleteDone", {
	buffer = 0,
	group = vim.api.nvim_create_augroup("HtmlSnippets" .. vim.api.nvim_get_current_buf(), { clear = true }),
	callback = function()
		local item = vim.v.completed_item
		local trigger = type(item.user_data) == "table" and item.user_data.html_snippet
		if not trigger then
			return
		end
		-- Remove the inserted trigger text, then expand the snippet in its place.
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		vim.api.nvim_buf_set_text(0, row - 1, col - #trigger, row - 1, col, {})
		vim.snippet.expand(snippets[trigger])
	end,
})
