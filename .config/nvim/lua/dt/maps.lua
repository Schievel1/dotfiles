-------------------------------------------------
-- DT'S NEOVIM CONFIGURATION
-- Neovim website: https://neovim.io/
-- DT's dotfiles: https://gitlab.com/dwt1/dotfiles
-------------------------------------------------

-------------------------------------------------
-- KEYBINDINGS
-------------------------------------------------

local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end
-- don't jump when exiting insert mode
map("i", "<Esc>", "<ESC>`^")
-- Mimic shell movements
map("i", "<C-E>", "<ESC>A")
map("i", "<C-A>", "<ESC>I")

-- Load recent sessions
map("n", "<leader>sl", "<CMD>SessionLoad<CR>")

-- Keybindings for telescope
map("n", "<leader>fr", "<CMD>Telescope oldfiles<CR>")
map("n", "<leader>ff", "<CMD>Telescope find_files<CR>")
map("n", "<leader>fp", "<CMD>Telescope file_browser path=~/.config/nvim<CR>")
map("n", "<leader><leader>", "<CMD>Telescope find_files<CR>")
map("n", "<leader>fb", "<CMD>Telescope file_browser path=%:p:h select_buffer=true<CR>")
map("n", "<leader>o-", "<CMD>Telescope file_browser cwd_to_path=true select_buffer=true<CR>")
map("n", "<leader>.", "<CMD>Telescope file_browser path=%:p:h select_buffer=true<CR>")
map("n", "<leader>od", "<CMD>Telescope file_browser path=%:p:h select_buffer=true<CR>")
map("n", "<leader>sd", "<CMD>Telescope live_grep<CR>")
map("n", "<leader>ht", "<CMD>Telescope colorscheme<CR>")

-- my keybindings to mimic some Doom Emacs things
map("n", "<leader>qq", "<CMD>quitall<CR>")
map("n", "<leader>gg", "<CMD>Magit<CR>")
--- sync
map("n", "<leader>hrr", "<CMD>PackerSync<CR>")
--- buffer things
map('n', '<leader>bs', '<Cmd>write<CR>', opts)
map('n', '<leader>bk', '<Cmd>BufferClose<CR>', opts)
map('n', '<leader>bK', '<Cmd>BufferCloseButCurrent<CR>', opts)
map('n', 'gT', '<Cmd>BufferPrevious<CR>', opts)
map('n', 'gt', '<Cmd>BufferNext<CR>', opts)
map('n', '<leader>bp', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<leader>bn', '<Cmd>BufferNext<CR>', opts)
--- windows and splits
map("n", "<leader>wv", "<CMD>vsplit<CR>")
map("n", "<leader>ws", "<CMD>split<CR>")
map("n", "<leader>wc", "<CMD>q<CR>")
map("n", "<C-h>", "<CMD>wincmd h<CR>")
map("n", "<C-t>", "<CMD>wincmd j<CR>")
map("n", "<C-n>", "<CMD>wincmd k<CR>")
map("n", "<C-s>", "<CMD>wincmd l<CR>")
map("n", "<leader>ww", "<CMD>wincmd w<CR>")

-- open things --
--- terminal
map('n', "<leader>ot", ":FloatermNew --name=myfloat --height=0.8 --width=0.7 --autoclose=2 zsh <CR> ")
map('n', "<leader>ot", ":FloatermToggle<CR>")
map('t', "<Esc>", "<C-\\><C-n>:q<CR>")
--- sidebar
map('n', "<leader>op", "<cmd>NERDTreeToggle<cr>")

-- Vimspector
vim.cmd([[
nmap <F9> <cmd>call vimspector#Launch()<cr>
nmap <F5> <cmd>call vimspector#StepOver()<cr>
nmap <F8> <cmd>call vimspector#Reset()<cr>
nmap <F11> <cmd>call vimspector#StepOver()<cr>")
nmap <F12> <cmd>call vimspector#StepOut()<cr>")
nmap <F10> <cmd>call vimspector#StepInto()<cr>")
]])
map('n', "Db", ":call vimspector#ToggleBreakpoint()<cr>")
map('n', "Dw", ":call vimspector#AddWatch()<cr>")
map('n', "De", ":call vimspector#Evaluate()<cr>")

-- FloaTerm configuration
map('n', "<leader>ot", ":FloatermNew --name=myfloat --height=0.8 --width=0.7 --autoclose=2 zsh <CR> ")
map('n', "t", ":FloatermToggle myfloat<CR>")
map('t', "<Esc>", "<C-\\><C-n>:q<CR>")

