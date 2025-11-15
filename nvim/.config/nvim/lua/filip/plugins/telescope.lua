return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
        "folke/todo-comments.nvim",
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")

        telescope.setup({
            defaults = {
                -- path_display = { "smart" },
                mappings = {
                    i = {
                        ["<C-h>"] = function(prompt_bufnr)
                            local prompt = require("telescope.actions.state").get_current_line()
                            actions.close(prompt_bufnr);

                            builtin.find_files({
                                hidden = true,
                                default_text = prompt,
                            })
                        end,
                        ["<C-s>"] = actions.select_vertical,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
            pickers = {
                -- find_files = {
                --     theme = "dropdown",
                -- }
            },
        })

        telescope.load_extension("fzf")

        -- set keymaps
        local keymap = vim.keymap

        keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
        keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
        keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Find string in cwd" })
        keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Find string under cursor in cwd" })
        keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help tags" })
        keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
    end,
}
