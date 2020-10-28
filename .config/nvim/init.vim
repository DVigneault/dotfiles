set syntax=on      " Turn on code syntax highlighting by default.
set nu             " Turn on line numbering.
set wrap linebreak " Wrap lines longer than the window.
set showcmd		    " Show (partial) command in status line.
set showmatch		  " Show matching brackets.
set ignorecase		  " Do case insensitive matching
set smartcase		  " Do smart case matching
set incsearch		  " Incremental search
set autowrite		  " Save before commands like :next and :make
set hidden		      " Hide buffers when they are abandoned
set cursorline     " Highlight present line

set tabstop=2      " number of visual spaces per TAB
set softtabstop=2  " number of spaces in tab when editing
set shiftwidth=2   " number of spaces to use for autoindent
set expandtab      " tabs are space
set autoindent
set copyindent     " copy indent from the previous line

" Plugin Manager:
"   https://github.com/junegunn/vim-plug
" Update Plugins:
"   nvim
"   :PlugInstall
"   :UpdateRemotePlugins
"   :q!
"   :q!
call plug#begin()

"https://github.com/morhetz/gruvbox
Plug 'morhetz/gruvbox'

call plug#end()

autocmd vimenter * colorscheme gruvbox " Activate Gruvbox

let g:gruvbox_italic = 1
let g:gruvbox_contrast_dark = 'hard'
