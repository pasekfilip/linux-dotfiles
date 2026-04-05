return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
        "williamboman/mason.nvim",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        local virtual_text = require("nvim-dap-virtual-text")

        dapui.setup()
        virtual_text.setup({
            enabled = true,                     -- enable this plugin (default)
            enabled_commands = true,            -- create commands DapVirtualTextEnable, DapVirtualTextDisable, etc.
            highlight_changed_variables = true, -- highlight changed values with a different color
            highlight_new_as_changed = false,   -- highlight new variables in the same way as changed variables
            show_stop_reason = true,            -- show stop reason when stopped on a breakpoint
            commented = true,                   -- prefix virtual text with comment string
            only_manually_hidden = false,       -- only hide virtual text when issued a command
            -- virt_text_pos = 'eol',              -- position of virtual text, see `:h nvim_buf_set_extmark()`
        })

        -- 1. ADAPTER SETUP (This is what was missing!)
        -- We need to tell DAP where the codelldb binary is
        dap.adapters.codelldb = {
            type = 'server',
            port = "${port}",
            executable = {
                -- On Arch, Mason installs things here:
                command = vim.fn.expand("$HOME/.local/share/nvim/mason/bin/codelldb"),
                args = { "--port", "${port}" },
            }
        }

        -- 2. UI AUTOMATION
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close() -- Fixed: was dap.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close() -- Fixed: was dap.close()
        end

        -- 3. CONFIGURATION
        dap.configurations.cpp = {
            {
                name = "Launch file",
                type = "codelldb",
                request = "launch",
                program = function()
                    -- This finds your binary in the current folder
                    local path = vim.fn.getcwd() .. '/render_buzz'
                    if vim.fn.executable(path) == 1 then
                        return path
                    else
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                -- If you need to pass arguments to your game:
                -- args = {"--fullscreen"},
            },
        }

        -- 4. KEYMAPS (Ensuring they are set globally)
        local set = vim.keymap.set
        set("n", "<F4>", dap.continue, { desc = "Debug: Start/Continue" })
        set("n", "<F7>", dap.terminate, { desc = "Debug: Terminate" })
        set("n", "<F8>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
        set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
        set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
        set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
    end
}
