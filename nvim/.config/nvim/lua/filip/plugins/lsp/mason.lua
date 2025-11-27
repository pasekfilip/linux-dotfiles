return {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        ensure_installed = {
            "html",
            "cssls",
            -- "lua_ls",
            "dockerls",
            "jsonls",
            "yamlls",
            -- "pyright",
            -- "clangd",
            -- "powershell_es",
            "angularls",
            "jdtls",
            "ts_ls",
        }
    },
    dependencies = {
        "williamboman/mason.nvim",
    },
    config = function()
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")

        -- enable mason and configure icons
        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            automatic_installation = false,
            automatic_enable = true,
        })
    end,
}
