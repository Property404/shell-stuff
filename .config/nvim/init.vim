call plug#begin('~/.config/nvim/plugged')
Plug 'fetlang/vim-fetlang'
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'wellle/tmux-complete.vim'
Plug 'Property404/molokai'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
" Plug 'Shougo/neco-syntax'
call plug#end()


" Color
" let g:molokai_original = 1
color molokai

" Autocomplete stuff
" This reduces startup time let g:python3_host_prog = "/usr/bin/python3"
" Only start on InsertEnter 
" let g:deoplete#enable_at_startup = 0
" autocmd InsertEnter * call deoplete#enable()

" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" Short tabs
set ts=4 sw=4

set relativenumber
set number
set autowrite

