local opt = vim.opt

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.undotree_DiffCommand = "diff"

-- Basic settings
opt.number = true         -- Line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true     -- Highlight current line
opt.wrap = false          -- Don't wrap lines
opt.scrolloff = 10        -- Keep 10 lines above/below cursor
opt.sidescrolloff = 8     -- Keep 8 columns left/right of cursor

-- Indentation
opt.tabstop = 4        -- Tab width
opt.shiftwidth = 4     -- Indent width
opt.softtabstop = 4    -- Soft tab stop
opt.expandtab = true   -- Use spaces instead of tabs
opt.smartindent = true -- Smart auto-indenting
opt.autoindent = true  -- Copy indent from current line

-- Search settings
opt.ignorecase = true    -- Case insensitive search
opt.smartcase = true     -- Case sensitive if uppercase in search
opt.hlsearch = true      -- Don't highlight search results
opt.incsearch = true     -- Show matches as you type
opt.inccommand = 'split' -- When doing /%s it opens split for preview

-- Visual settings
opt.termguicolors = true                      -- Enable 24-bit colors
opt.signcolumn = "yes"                        -- Always show sign column
-- opt.colorcolumn = "150"                    -- Show column at 100 characters
opt.showmatch = true                          -- Highlight matching brackets
opt.matchtime = 2                             -- How long to show matching bracket
opt.cmdheight = 1                             -- Command line height
opt.completeopt = "menuone,noinsert,noselect" -- Completion options
opt.showmode = false                          -- Don't show mode in command line
opt.pumheight = 10                            -- Popup menu height
opt.pumblend = 10                             -- Popup menu transparency
opt.winblend = 0                              -- Floating window transparency
opt.conceallevel = 0                          -- Don't hide markup
opt.concealcursor = ""                        -- Don't hide cursor line markup
opt.lazyredraw = true                         -- Don't redraw during macros
opt.synmaxcol = 300                           -- Syntax highlighting limit
opt.more = true                               -- When message dosent fit on the screen it shows -- more --

-- File handling
opt.backup = false                            -- Don't create backup files
opt.writebackup = false                       -- Don't create backup before writing
opt.swapfile = false                          -- Don't create swap files
opt.undofile = true                           -- Persistent undo
opt.undodir = vim.fn.expand("~/.vim/undodir") -- Undo directory
opt.updatetime = 300                          -- Faster completion
opt.timeoutlen = 500                          -- Key timeout duration
opt.ttimeoutlen = 0                           -- Key code timeout
opt.autoread = true                           -- Auto reload files changed outside vim
opt.autowrite = false                         -- Don't auto save
opt.shada = { "'10", "<0", "s10", "h" }

-- Behavior settings
opt.hidden = true                   -- Allow hidden buffers
opt.errorbells = false              -- No error bells
opt.backspace = "indent,eol,start"  -- Better backspace behavior
opt.autochdir = false               -- Don't auto change directory
opt.iskeyword:append("-")           -- Treat dash as part of word
opt.path:append("**")               -- include subdirectories in search
opt.selection = "exclusive"         -- Selection behavior
opt.mouse = "a"                     -- Enable mouse support
opt.clipboard:append("unnamedplus") -- Use system clipboard
opt.modifiable = true               -- Allow buffer modifications
opt.encoding = "UTF-8"              -- Set encoding
opt.wildmode = "longest:full,full"  -- Command-line completion mode

-- Split behavior
opt.splitbelow = true -- Horizontal splits go below
opt.splitright = true -- Vertical splits go right

-- Folding settings
opt.foldmethod = "expr"                          -- Use expression for folding
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use treesitter for folding
opt.foldlevel = 99                               -- Start with all folds open

-- Performance improvements
opt.redrawtime = 10000
opt.maxmempattern = 20000

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = "java",
--     callback = function()
--         vim.bo.shiftwidth = 2
--         vim.bo.tabstop = 2
--         vim.softtabstop = 2
--     end
-- })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt.formatoptions = "jql"
    end,
})
--
-- local projectFile = vim.fn.filereadable(vim.fn.getcwd() .. '/project.godot')
-- if projectFile > 0 then
-- 	vim.fn.serverstart("127.0.0.1:6666")
-- end
