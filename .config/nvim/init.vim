:syntax on                      " Turn on code syntax highlighting by default.
:set nu                         " Turn on line numbering.
:set wrap linebreak             " Wrap lines longer than the window.
:set showcmd		        " Show (partial) command in status line.
:set showmatch		        " Show matching brackets.
:set ignorecase		        " Do case insensitive matching
:set smartcase		        " Do smart case matching
:set incsearch		        " Incremental search
:set autowrite		        " Automatically save before commands like :next and :make
:set hidden		        " Hide buffers when they are abandoned
:set backspace=indent,eol,start " Fix backspace problems on Unix

" Plugin Manager:
"   https://github.com/junegunn/vim-plug
" Update Plugins:
"   nvim
"   :PlugInstall
"   :UpdateRemotePlugins
"   :q!
"   :q!
call plug#begin()
Plug 'morhetz/gruvbox'
call plug#end()

autocmd vimenter * colorscheme gruvbox " Activate Gruvbox
