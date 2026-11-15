return {
    {
        "stevearc/oil.nvim",
        dependencies = {
            { "nvim-tree/nvim-web-devicons" },
        },
        lazy = false,
        config = function()
            require("oil").setup({
                columns = {
                    "permissions",
                    "size",
                    "mtime",
                    "icon",
                },
                view_options = {
                    show_hidden = true,
                },
                keymaps = {
                    ["<C-s>"] = false,
                    ["<C-h>"] = false,
                    ["<C-l>"] = false,
                    ["g!"] = "actions.open_cmdline",
                },
            })
        end,
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" }),
    },
}
