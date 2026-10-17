-- jdtls settings, merged over nvim-lspconfig's lsp/jdtls.lua. In after/ so
-- this file is guaranteed to win over the plugin's (:h lsp-config-merge).
-- Enabled from lua/plugins/lspconfig.lua; the jdt:// reader lives there too.

local mason = vim.fn.stdpath("data") .. "/mason"

-- java-debug-adapter bundle (installed via Mason or auto-installed in debug.lua)
local debug_jar = vim.fn.glob(
	mason .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
	true
)
local bundles = {}
if debug_jar ~= "" then
	table.insert(bundles, debug_jar)
end

-- Read by the jdtls launcher script, so it has to be in nvim's environment
-- before the server is spawned. This file is evaluated before that.
vim.env.JDTLS_JVM_ARGS = table.concat({
	"-javaagent:" .. mason .. "/packages/jdtls/lombok.jar",
	"-Xmx4g",
	"-XX:+UseG1GC",
	"-XX:+UseStringDeduplication",
	"-Dlog.level=ERROR",
}, " ")

return {
	init_options = {
		bundles = bundles,
		extendedClientCapabilities = {
			classFileContentsSupport = true,
		},
	},
	settings = {
		java = {
			autobuild = {
				enabled = false,
			},
			references = {
				includeAccessors = true,
				includeDecompiledSources = true,
			},
			configuration = {
				updateBuildConfiguration = "automatic",
				runtimes = {
					{ name = "JavaSE-11", path = "/usr/lib/jvm/java-11-amazon-corretto" },
					{ name = "JavaSE-21", path = "/usr/lib/jvm/java-21-amazon-corretto", default = true },
				},
			},
			format = { enabled = true },
			saveActions = { organizeImports = true },
		},
	},
}
