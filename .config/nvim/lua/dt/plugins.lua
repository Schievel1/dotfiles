-------------------------------------------------
-- DT'S NEOVIM CONFIGURATION
-- Neovim website: https://neovim.io/
-- DT's dotfiles: https://gitlab.com/dwt1/dotfiles
-------------------------------------------------

local status, packer = pcall(require, "packer")
if not status then
	print("Packer is not installed")
	return
end

-- Reloads Neovim after whenever you save plugins.lua
vim.cmd([[
    augroup packer_user_config
      autocmd!
     autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup END
]])

packer.startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- Dashboard is a nice start screen for nvim
	use("glepnir/dashboard-nvim")

	-- Telescope
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use("nvim-telescope/telescope-file-browser.nvim")

	use("nvim-treesitter/nvim-treesitter") -- Treesitter Syntax Highlighting

	-- Productivity
	use("vimwiki/vimwiki")
	use("jreybert/vimagit")
	use("nvim-orgmode/orgmode")

	use("folke/which-key.nvim") -- Which Key
	--use("nvim-lualine/lualine.nvim") -- A better statusline
    use 'beauwilliams/statusline.lua'

	-- File management --
	use("vifm/vifm.vim")
	use("scrooloose/nerdtree")
	use("tiagofumo/vim-nerdtree-syntax-highlight")
	use("ryanoasis/vim-devicons")

	-- Tim Pope Plugins --
	use("tpope/vim-surround")

	-- Syntax Highlighting and Colors --
	use("PotatoesMaster/i3-vim-syntax")
	use("kovetskiy/sxhkd-vim")
	use("vim-python/python-syntax")
	use("ap/vim-css-color")

	-- Junegunn Choi Plugins --
	use("junegunn/goyo.vim")
	use("junegunn/limelight.vim")
	use("junegunn/vim-emoji")

	-- Colorschemes --
	use("RRethy/nvim-base16")
	use("kyazdani42/nvim-palenight.lua")
    use("folke/tokyonight.nvim")

    -- LSP -- 
	use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use 'neovim/nvim-lspconfig' 

    -- Debugger -- 
    use 'puremourning/vimspector' -- Requires USE=python3 of vim somehow??

    -- Rust -- 
    use 'simrat39/rust-tools.nvim'

    -- Completion framework:
    use 'hrsh7th/nvim-cmp' 

    -- LSP completion source:
    use 'hrsh7th/cmp-nvim-lsp'

    -- Useful completion sources:
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-vsnip'                             
    use 'hrsh7th/cmp-path'                              
    use 'hrsh7th/cmp-buffer'                            
    use 'hrsh7th/vim-vsnip' 

    -- tabs -- 
    use {'romgrk/barbar.nvim', requires = {
        'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
        'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
        }
    }
	-- Other stuff --
	use("frazrepo/vim-rainbow")
    use 'voldikss/vim-floaterm'
    use 'tommcdo/vim-lion'
    use 'lambdalisue/suda.vim'

	if packer_bootstrap then
		packer.sync()
	end
end)


