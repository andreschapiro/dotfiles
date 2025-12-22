-- Documentation: https://neovim.io/doc/user/options.html

local vg = vim.g
local vb = vim.bo
local vw = vim.wo
local vo = vim.opt

-- Global variables
Homedir = os.getenv("HOME")
Sessiondir = vim.fn.stdpath("data") .. "/sessions"

-- Global options
vg.mapleader = " " -- space is the leader!
vg.maplocalleader = "\\"

-- Enable filetype detection, plugins, and indent
vim.cmd("filetype plugin indent on")

-- Buffer options
-- Note: autoindent and smartindent are disabled in favor of treesitter indent
-- vb.autoindent = true
-- vb.smartindent = true
vb.expandtab = true -- Use spaces instead of tabs
vb.shiftwidth = 2 -- Size of an indent
vb.softtabstop = 2 -- Number of spaces tabs count for
vb.tabstop = 2 -- Number of spaces in a tab
-- vb.wrapmargin = 1

-- Vim options
vo.cmdheight = 0 -- Hide the command bar
vim.schedule(function()
  vo.clipboard = "unnamedplus" -- Use the system clipboard
end)
vo.confirm = true
vo.completeopt = { "menuone", "noselect" } -- Completion opions for code completion
vo.cursorlineopt = "screenline,number" -- Highlight the screen line of the cursor with CursorLine and the line number with CursorLineNr
vo.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  diff = " ",
  eob = " ",
}

vo.foldcolumn = "0" -- Fold column handled by Snacks statuscolumn
vo.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vo.foldlevelstart = 99
vo.foldenable = true

vo.smartcase = true -- Switch to case-sensitive when there is a capital letter in the search
vo.ignorecase = true -- Ignore case when searching

vo.inccommand = "split"

vo.laststatus = 3 -- Use global statusline

-- Sets how Neovim will display certain whitespace characters in the editor
vo.list = true
vo.listchars = { trail = "·", nbsp = "␣" }

-- Ensure tabs are converted to spaces
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

vo.modelines = 1 -- Only use folding settings for this file
vo.mouse = "a" -- Use the mouse in all modes

vo.shiftround = true -- Round indent
vo.shortmess = {
  A = true, -- ignore annoying swap file messages
  c = true, -- Do not show completion messages in command line
  F = true, -- Do not show file info when editing a file, in the command line
  I = true, -- Do not show the intro message
  W = true, -- Do not show "written" in command line when writing
}
-- vo.showcmd = true -- Do not show me what I'm typing
vo.showmatch = true -- Show matching brackets by flickering
vo.showmode = false -- Do not show the mode
vo.sidescrolloff = 8 -- The minimal number of columns to keep to the left and to the right of the cursor if 'nowrap' is set
vo.smoothscroll = true -- Smoother scrolling
vo.splitbelow = true -- Put new windows below current
vo.splitright = true -- Put new windows right of current
vim.opt.splitkeep = "screen"
-- vo.termguicolors = true -- True color support
vo.textwidth = 120 -- Total allowed width on the screen
vo.timeoutlen = 100 -- Time in milliseconds to wait for a mapped sequence to complete
vo.updatetime = 150 -- If in this many milliseconds nothing is typed, the swap file will be written to disk
vo.wildmode = "list:longest" -- Command-line completion mode
vo.wildignore = { "*/.git/*", "*/node_modules/*" } -- Ignore these files/folders

-- Create folders for our backups, undos, swaps and sessions if they don't exist
vim.schedule(function()
  vim.cmd("silent call mkdir(stdpath('data').'/backups', 'p', '0700')")
  vim.cmd("silent call mkdir(stdpath('data').'/undos', 'p', '0700')")
  vim.cmd("silent call mkdir(stdpath('data').'/swaps', 'p', '0700')")
  vim.cmd("silent call mkdir(stdpath('data').'/sessions', 'p', '0700')")

  vo.backupdir = vim.fn.stdpath("data") .. "/backups" -- Use backup files
  vo.directory = vim.fn.stdpath("data") .. "/swaps" -- Use Swap files
  vo.undodir = vim.fn.stdpath("data") .. "/undos" -- Set the undo directory
end)

vo.undofile = true -- Maintain undo history between sessions
-- vo.undolevels = 1000 -- Ensure we can undo a lot!

-- Session options - exclude terminal buffers from sessions
vo.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos"

-- Window options
vw.colorcolumn = "80,120" -- Make a ruler at 80px and 120px
vw.number = true -- Set the absolute number
vw.relativenumber = true -- Set the relative number
vw.signcolumn = "yes" -- Show information next to the line numbers
vw.wrap = false -- Do not display text over multiple lines
