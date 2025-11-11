return {
    {
        'stevearc/oil.nvim',
        dependencies = {
        { 'nvim-tree/nvim-web-devicons' },
        { 'adelarsq/image_preview.nvim', lazy = true },
        },
        lazy = false,
        config = function()
            local image_preview = require("image_preview");
            require("oil").setup {
                columns = { "icon" },
                keymaps = {
                    ["<leader>i"] = {
                        callback = function()
                            image_preview.PreviewImageOil();
                        end,
                    },
                    ["<C-s>"] = false,
                    ["<C-h>"] = false,
                    ["<C-l>"] = false,
                }
            }
        end,
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    }
}
