--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
      end,
    },
  },

  {
    -- Theme inspired by Atom
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    --[[ opts = {
      options = {
        icons_enabled = false,
        theme = 'tokyonight',
        component_separators = '|',
        section_separators = '',
      },
    }, ]]
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'tokyonight',
          section_separators = '',
          component_separators = '|',
        },
        sections = {
          lualine_a = { {
            'mode',
            fmt = function(str)
              return string.sub(str, 1, 1)
            end
          } },
          lualine_b = { { 'branch', icon = '' } },
          lualine_c = { 'filename' },
          lualine_x = { 'diagnostics', 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      exclude = {
        filetypes = {
          "dashboard",
        },
      },
    },
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    "jedrzejboczar/possession.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  {
    "github/copilot.vim",
  },
  {
    'nvim-orgmode/orgmode',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter', lazy = true },
    },
    event = 'VeryLazy',
    config = function()
      -- Load treesitter grammar for org
      require('orgmode').setup_ts_grammar()

      -- Setup treesitter
      require('nvim-treesitter.configs').setup({
        highlight = {
          enable = true,
        },
        ensure_installed = { 'org' },
      })

      -- Setup orgmode
      require('orgmode').setup({
        org_agenda_files = '~/orgfiles/**/*',
        org_default_notes_file = '~/orgfiles/refile.org',
      })
    end,
  },

  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        theme = 'doom',
        config = {
          header = {
            "                                                       ",
            "                                                       ",
            "                                                       ",
            " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
            " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
            " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
            " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
            " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
            " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
            "                                                       ",
            "                                                       ",
            "                                                       ",
            "                                                       ",
          },
          center = {
            {
              icon = "󰈞  ",
              desc = "Find  File                              ",
              --[[ action = "Leaderf file --popup", ]]
              key = "SPC f f",
            },
            {
              icon = "󰈢  ",
              desc = "Recently opened files                   ",
              --[[ action = "Leaderf mru --popup", ]]
              key = "SPC f r",
            },
            {
              icon = "󰈬  ",
              desc = "Open sessien                            ",
              --[[ action = "Leaderf rg --popup", ]]
              key = "SPC s s",
            },
            {
              icon = "  ",
              desc = "Open Nvim config                        ",
              --[[ action = "tabnew ~/.config/nvim/ | tcd %:p:h", ]]
              key = "SPC f p",
            },
            {
              icon = "󰗼  ",
              desc = "Quit Nvim                               ",
              -- desc = "Quit Nvim                               ",
              --[[ action = "qa", ]]
              key = "SPC q q",
            },
          },
          footer = {} --your footer
        }
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } }
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  {
    "roobert/surround-ui.nvim",
    dependencies = {
      "kylechui/nvim-surround",
      "folke/which-key.nvim",
    },
    config = function()
      require("surround-ui").setup({
        root_key = "S"
      })
    end,
  },

  {
    "xiyaowong/transparent.nvim",
  },

  {
    "mbbill/undotree",
  },

  {
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    "HiPhish/nvim-ts-rainbow2",
    dependencies = {
      "nvim-treesitter/nvim-treesitter"
    },
  },
  
  {
    "X3eRo0/dired.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim"
    },
  },

  {
    "lambdalisue/suda.vim",
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- switch on transparency from transparent.nvim
vim.g.transparent_enabled = true

-- open splits on the right like doom does
vim.o.splitright = true

-- auto switch to sudo
vim.g.suda_smart_edit = 1

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader><Space>', builtin.find_files, {})
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>sd', builtin.live_grep, {})
vim.keymap.set('n', '<leader>bb', builtin.buffers, {})
vim.keymap.set('n', '<leader>,', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<M-x>',  builtin.commands, {})

--[[ vim.keymap.set('n', '<leader>.', require "telescope".extensions.file_browser.file_browser, {}) ]]
--[[ vim.keymap.set('n', '<leader>ff', require "telescope".extensions.file_browser.file_browser, {}) ]]
vim.api.nvim_set_keymap(
  "n",
  "<leader>.",
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { noremap = true }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>f",
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { noremap = true }
)

vim.keymap.set('n', '<leader>bs', vim.cmd.write, {})
vim.keymap.set('n', '<leader>bS', vim.cmd.SudaWrite, {})
vim.keymap.set('n', '<leader>bk', vim.cmd.bd, {})
vim.keymap.set('n', '<leader>bn', vim.cmd.bn, {})
vim.keymap.set('n', '<leader>bp', vim.cmd.bp, {})
vim.keymap.set('n', '\'', '<C-6>', {})
vim.keymap.set('n', '<leader>qq', vim.cmd.quitall, {})

vim.keymap.set('i', '<ESC>', vim.cmd.normal, {})

-- don't go back one character when leaving insert mode
vim.cmd("imap <esc> <esc>`^")

-- C-g acts similar to emacs (more or less
vim.cmd("map <C-g> <esc>")
vim.cmd("imap <C-g> <esc>")
vim.cmd("set whichwrap+=<,>,[,]")

-- activate cursor line
vim.cmd("set cursorline")

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
--[[ vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' }) ]]

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

local fb_utils = require "telescope._extensions.file_browser.utils"
local action_state = require "telescope.actions.state"
local function goto_root(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  local finder = current_picker.finder
  finder.path = '/'

  fb_utils.redraw_border_title(current_picker)
  current_picker:refresh(
    finder,
    { new_prefix = fb_utils.relative_path_prefix(finder), reset_prompt = true, multi = current_picker._multi }
  )
end

require("telescope").setup {
  pickers = {
    find_files = {
      theme = 'ivy',
      --[[ find_command = 'rg --files --hidden --smart-case', ]]
    },
  },
  extensions = {
    file_browser = {
      theme = "ivy",
      hidden = { file_browser = false, folder_browser = false },
      prompt_path = true,
      display_stat = { date = true, size = true, mode = true },
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
      use_fd = true,
      --[[ cwd_to_path = true, ]]
      dir_icon = "",
      mappings = {
        ["i"] = {
          -- your custom insert mode mappings
            ["<ESC>"] = require("telescope.actions").close,
            ["<tab>"] = require("telescope.actions").select_default,
            ["~/"] = require("telescope._extensions.file_browser.actions").goto_home_dir,
            ["//"] = goto_root,
        },
        ["n"] = {
          -- your custom normal mode mappings
        },
      },
    },
  },
}
-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
require("telescope").load_extension "file_browser"

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

require('telescope').load_extension('possession')

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep({
      search_dirs = { git_root },
    })
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>fr', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>fp', function()
  require('telescope.builtin').find_files({
    cwd = '~/.config/nvim',
  })
end, { desc = '[?] Find nvim config file' })


vim.keymap.set('n', '<leader>bb', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>sb', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sD', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
-- vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>ss', require('telescope').extensions.possession.list, { desc = '[S]earch [S]ession' })
vim.keymap.set('n', '<leader>su', vim.cmd.UndotreeToggle, { desc = '[S]earch [U]ndo Tree' })

-- Comments
vim.keymap.set('n', 'l', function()
    require('Comment.api').toggle.blockwise.current()
    vim.api.nvim_input('j')
  end,
  { desc = 'Comment current line (blockwise)' })
vim.keymap.set('n', 'L', function()
    require('Comment.api').toggle.linewise.current()
    vim.api.nvim_input('j')
  end,
  { desc = 'Comment current line (linewise)' })

local esc = vim.api.nvim_replace_termcodes(
  '<ESC>', true, false, true
)
vim.keymap.set('x', 'L', function()
    vim.api.nvim_feedkeys(esc, 'nx', false)
    require('Comment.api').toggle.linewise(vim.fn.visualmode())
end)
vim.keymap.set('x', 'l', function()
    vim.api.nvim_feedkeys(esc, 'nx', false)
    require('Comment.api').toggle.blockwise(vim.fn.visualmode())
end)

-- copilot
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

-- windows
vim.keymap.set('n', '<leader>wv', vim.cmd.vsplit, { silent = true })
vim.keymap.set('n', '<leader>ws', vim.cmd.split, { silent = true })
vim.keymap.set('n', '<leader>wc', vim.cmd.q, { silent = true })
vim.keymap.set('n', '<leader>ww', '<C-w><C-w>', { silent = true })
vim.keymap.set('n', '<leader>wm', vim.cmd.only, { silent = true })

-- open
vim.keymap.set('n', '<leader>o-', vim.cmd.Dired, { desc = 'Open Dired' } )
vim.keymap.set('n', '<leader>od', vim.cmd.Dired, { desc = 'Open Dired' } )

-- Harpoon
vim.keymap.set('n', '<leader>R', require("harpoon.mark").add_file, { desc = 'Add File to Harpoon' })
vim.keymap.set('n', '<leader>r', require("harpoon.ui").toggle_quick_menu, { desc = 'Toggle Harpoon menu' })
vim.keymap.set('n', '<leader>1', function()
    require("harpoon.ui").nav_file(1)
  end,
  { desc = 'Go to Harpoon location 1' })
vim.keymap.set('n', '<C-h>', function()
    require("harpoon.ui").nav_file(1)
  end,
  { desc = 'Go to Harpoon location 1' })
vim.keymap.set('n', '<leader>2', function()
    require("harpoon.ui").nav_file(2)
  end,
  { desc = 'Go to Harpoon location 2' })
vim.keymap.set('n', '<C-t>', function()
    require("harpoon.ui").nav_file(2)
  end,
  { desc = 'Go to Harpoon location 2' })
vim.keymap.set('n', '<leader>3', function()
    require("harpoon.ui").nav_file(3)
  end,
  { desc = 'Go to Harpoon location 3' })
vim.keymap.set('n', '<C-n>', function()
    require("harpoon.ui").nav_file(3)
  end,
  { desc = 'Go to Harpoon location 3' })
vim.keymap.set('n', '<leader>4', function()
    require("harpoon.ui").nav_file(4)
  end,
  { desc = 'Go to Harpoon location 4' })
vim.keymap.set('n', '<C-s>', function()
    require("harpoon.ui").nav_file(4)
  end,
  { desc = 'Go to Harpoon location 4' })
vim.keymap.set('n', '<leader>5', function()
    require("harpoon.ui").nav_file(5)
  end,
  { desc = 'Go to Harpoon location 5' })
vim.keymap.set('n', '<leader>6', function()
    require("harpoon.ui").nav_file(6)
  end,
  { desc = 'Go to Harpoon location 6' })
vim.keymap.set('n', '<leader>7', function()
    require("harpoon.ui").nav_file(7)
  end,
  { desc = 'Go to Harpoon location 7' })
vim.keymap.set('n', '<leader>8', function()
    require("harpoon.ui").nav_file(8)
  end,
  { desc = 'Go to Harpoon location 8' })
vim.keymap.set('n', '<leader>9', function()
    require("harpoon.ui").nav_file(9)
  end,
  { desc = 'Go to Harpoon location 9' })

-- git
vim.keymap.set('n', '<leader>gg', vim.cmd.Git, { desc = 'Open git' })
vim.keymap.set('n', 'gu', '<cmd>diffget //2<CR>')
vim.keymap.set('n', 'gh', '<cmd>diffget //3<CR>')
local autocmd = vim.api.nvim_create_autocmd
local ThePrimeagen_Fugitive = vim.api.nvim_create_augroup("ThePrimeagen_Fugitive", {})
autocmd("BufWinEnter", {
  group = ThePrimeagen_Fugitive,
  pattern = "*",
  callback = function()
    if vim.bo.ft ~= "fugitive" then
      return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local opts = { buffer = bufnr, remap = false }
    vim.keymap.set("n", "p", function()
      vim.cmd.Git('push')
    end, opts)

    -- rebase always
    vim.keymap.set("n", "F", function()
      vim.cmd.Git('pull --rebase')
    end, opts)

    vim.keymap.set("n", "f", function()
      vim.cmd.Git('fetch')
    end, opts)

    -- NOTE: It allows me to easily set the branch i am pushing and any tracking
    -- needed if i did not set the branch up correctly
    vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
  end,
})

--[[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
    rainbow = {
      enable = true,
      -- list of languages you want to disable the plugin for
      disable = { 'jsx', 'cpp' },
      -- Which query to use for finding delimiters
      query = 'rainbow-parens',
      -- Highlight the entire buffer all at once
      strategy = require('ts-rainbow').strategy.global,
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>cr', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>clrr', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('<leader>claa', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('<leader>cd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('<leader>ch', '<cmd>lua require"telescope.builtin".lsp_definitions({jump_type="vsplit"})<CR>',
    '[G]oto definition other window')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('<leader>cD', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>cI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>clD', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>clds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>clws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('<leader>cl==', vim.lsp.buf.format, 'Format current buffer')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
  --[[ ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' }, ]]
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  clangd = {},
  -- gopls = {},
  -- pyright = {},
  rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- setup possession
require('possession').setup {
  --[[ session_dir = (Path:new(vim.fn.stdpath('data')) / 'possession'):absolute(), ]]
  silent = false,
  load_silent = true,
  debug = false,
  logfile = false,
  prompt_no_cr = false,
  autosave = {
    current = true,   -- or fun(name): boolean
    tmp = true,       -- or fun(): boolean
    tmp_name = 'tmp', -- or fun(): string
    on_load = false,
    on_quit = true,
  },
  commands = {
    save = 'PossessionSave',
    load = 'PossessionLoad',
    rename = 'PossessionRename',
    close = 'PossessionClose',
    delete = 'PossessionDelete',
    show = 'PossessionShow',
    list = 'PossessionList',
    migrate = 'PossessionMigrate',
  },
  hooks = {
    before_save = function(name) return {} end,
    after_save = function(name, user_data, aborted) end,
    before_load = function(name, user_data) return user_data end,
    after_load = function(name, user_data) end,
  },
  plugins = {
    close_windows = {
      hooks = { 'before_save', 'before_load' },
      preserve_layout = true, -- or fun(win): boolean
      match = {
        floating = true,
        buftype = {},
        filetype = {},
        custom = false, -- or fun(win): boolean
      },
    },
    delete_hidden_buffers = {
      hooks = {
        'before_load',
        vim.o.sessionoptions:match('buffer') and 'before_save',
      },
      force = false, -- or fun(buf): boolean
    },
    nvim_tree = true,
    neo_tree = true,
    symbols_outline = true,
    tabby = true,
    dap = true,
    dapui = true,
    neotest = true,
    delete_buffers = false,
  },
  telescope = {
    previewer = {
      enabled = true,
      previewer = 'pretty', -- or 'raw' or fun(opts): Previewer
      wrap_lines = true,
      include_empty_plugin_data = false,
      cwd_colors = {
        cwd = 'Comment',
        tab_cwd = { '#cc241d', '#b16286', '#d79921', '#689d6a', '#d65d0e', '#458588' }
      }
    },
    list = {
      default_action = 'load',
      mappings = {
        save = { n = '<c-s>', i = '<c-s>' },
        load = { n = '<c-l>', i = '<c-l>' },
        delete = { n = '<c-d>', i = '<c-d>' },
        rename = { n = '<c-r>', i = '<c-r>' },
      },
    },
  },
}
-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<Tab>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

require("transparent").setup({ -- Optional, you don't have to run setup.
  groups = {                   -- table: default groups
    'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
    'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
    'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
    'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
    'EndOfBuffer',
  },
  extra_groups = {},   -- table: additional groups that should be cleared
  exclude_groups = {}, -- table: groups you don't want to clear
})

require("dired").setup({
    path_separator = "/",                -- Use '/' as the path separator
    show_hidden = true,                  -- Show hidden files
    show_icons = false,                  -- Show icons (patched font required)
    show_banner = false,                 -- Do not show the banner
    hide_details = false,                -- Show file details by default
    sort_order = "name",                 -- Sort files by name by default

    -- Define keybindings for various 'dired' actions
    keybinds = {
        dired_enter = "<cr>",
        dired_back = "-",
        dired_up = "h",
        dired_rename = "R",
        dired_mark = "m",
        dired_delete_marked = "x",
        dired_quit = "q",
    },

    -- Define colors for different file types and attributes
    colors = {
        DiredDimText = { link = {}, bg = "NONE", fg = "505050", gui = "NONE" },
        DiredDirectoryName = { link = {}, bg = "NONE", fg = "9370DB", gui = "NONE" },
        -- ... (define more colors as needed)
        DiredMoveFile = { link = {}, bg = "NONE", fg = "ff3399", gui = "bold" },
    },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
