-- angularls settings, merged over nvim-lspconfig's lsp/angularls.lua (in
-- after/ so this one wins, :h lsp-config-merge). Enabled from
-- lua/plugins/lspconfig.lua.

-- Find the project root directory.
-- This looks upwards from the current file for a '.git' directory or an 'angular.json' file.
local project_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1] or vim.fn.findcwd({ "nx.json" })
local ngserver_path = project_root .. "/node_modules/.bin/ngserver"
local node_modules_path = project_root .. "/node_modules"

return {
	cmd = {
		ngserver_path,
		"--stdio",
		"--tsProbeLocations",
		node_modules_path,
		"--ngProbeLocations",
		node_modules_path,
	},
	-- filetypes = { "typescript", 'htmlangular' },
	-- root_markers = { 'angular.json', 'project.json', 'package.json', '.git' },
}
