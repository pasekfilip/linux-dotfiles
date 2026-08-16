local function get_lsp_name()
	local msg = "LS Inactive"
	local buf_clients = vim.lsp.get_clients()
	if next(buf_clients) == nil then
		if type(msg) == "boolean" or #msg == 0 then
			return "LS Inactive"
		end
	end
	local buf_client_names = {}

	for _, client in pairs(buf_clients) do
		table.insert(buf_client_names, client.name)
	end

	local unique_client_names = vim.fn.uniq(buf_client_names)

	local language_servers = "[" .. table.concat(unique_client_names, ", ") .. "]"
	return language_servers
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	priority = 100,
	config = function()
		local lualine = require("lualine")

		-- "auto" derives the statusline from the active colorscheme, so it
		-- follows the Omarchy theme. lualine re-runs setup() on ColorScheme,
		-- which is what makes a live theme switch recolour the bar too.
		-- (This replaced a hardcoded blue/teal-on-#112638 palette.)
		lualine.setup({
			options = {
				theme = "auto",
			},
			sections = {
				lualine_x = {
					get_lsp_name,
					{
						function()
							return os.date("%H:%M")
						end
					}
				},
				lualine_y = {
					'filetype',
				},
				lualine_z = {
					'progress'
				},
			},
		})
	end,
}
