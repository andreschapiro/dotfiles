set nocompatible              " be iMproved, required
syntax on
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'joshdick/onedark.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'airblade/vim-gitgutter'
Plugin 'vim-scripts/grep.vim'
Plugin 'vim-scripts/CSApprox'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'Raimondi/delimitMate'
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/syntastic'
Plugin 'avelino/vim-bootstrap-updater'
Plugin 'sheerun/vim-polyglot'
Plugin 'fatih/vim-go'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'gorodinskiy/vim-coloresque'
Plugin 'tpope/vim-haml'
Plugin 'mattn/emmet-vim'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'davidhalter/jedi-vim'
Plugin 'raimon49/requirements.txt.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"
set number
colorscheme onedark
