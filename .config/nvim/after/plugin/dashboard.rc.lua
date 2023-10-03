-------------------------------------------------
-- DT'S NEOVIM CONFIGURATION
-- Neovim website: https://neovim.io/
-- DT's dotfiles: https://gitlab.com/dwt1/dotfiles
-------------------------------------------------

local status, db = pcall(require, "dashboard")
local home = os.getenv("HOME")

-- linux
--db.preview_command = 'ueberzug'
--
--db.preview_file_path = home .. '/.config/nvim/static/neovim.cat'
db.setup({
theme = 'doom',
config = {
header = {
	"",
	"",
	" ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
	" ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
	" ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
	" ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
	" ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
	" ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
	"",
	"",
},
    center = {
	{
		icon = "  ",
		desc = "Recent sessions                         ",
		shortcut = "SPC s l",
		action = "SessionLoad",
	},
	{
		icon = "  ",
		desc = "Find recent files                       ",
		action = "Telescope oldfiles",
		shortcut = "SPC f r",
	},
	{
		icon = "  ",
		desc = "Find files                              ",
		action = "Telescope find_files find_command=rg,--hidden,--files",
		shortcut = "SPC f f",
	},
	{
		icon = "  ",
		desc = "File browser                            ",
		action = "Telescope file_browser",
		shortcut = "SPC f b",
	},
	{
		icon = "  ",
		desc = "Find word                               ",
		action = "Telescope live_grep",
		shortcut = "SPC f w",
	},
	{
		icon = "  ",
		desc = "Load new theme                          ",
		action = "Telescope colorscheme",
		shortcut = "SPC h t",
	},
},
footer = {}
}
})
