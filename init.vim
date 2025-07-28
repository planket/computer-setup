"modify hot keys
"inoremap jj <ESC> "map ESC to jj
"nnoremap ; : "map : to ;

"turn off swap
set noswapfile

"basic appearance
set list
"set listchars=tab:>- "show tabs with marker  
"set lcs=tab:»·     "show tabs
"set lcs=trail:·   "show trailing spaces
"set lcs+=extends:# "show line wrap
"set lcs+=nbsp:.    "show non breaking spaces



set showmatch               " show matching 
set ignorecase              " case insensitive 
set mouse=v                 " middle-click paste with 
set hlsearch                " highlight search 
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> 
                            " does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=80                  " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard



"plugins
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'dense-analysis/ale'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'Yggdroot/indentLine'
call plug#end()

" IndentLine settings (using Yggdroot/indentLine)
let g:indentLine_char = '│'
let g:indentLine_color_term = 15 
let g:indentLine_color_gui = '#93a1a1'
let g:indentLine_conceallevel = 2

" keybindings
" CoC keybindings
" Use Tab and Shift-Tab to navigate completion list
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Use Enter to confirm completion
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"



"Enable syntax highlighting
syntax enable



"Set color scheme 
set termguicolors
set background=dark
colorscheme solarized
"colorscheme desert
highlight Normal guibg=#002b36 ctermbg=0
highlight SpecialKey ctermfg=white guifg=white
highlight NonText ctermfg=white guifg=white
highlight String ctermfg=yellow guifg=#b58900
highlight LineNr ctermfg=yellow guifg=#b58900
highlight ColorColumn ctermbg=0 guibg=#073642

"nerdtree settings
" Start NERDTree and put the cursor back in the other window.
autocmd VimEnter * NERDTree | wincmd p
