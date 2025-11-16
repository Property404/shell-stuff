" Plug plugins
call plug#begin('~/.vim/plugged')
Plug 'lifepillar/vim-mucomplete'
Plug 'gryf/wombat256grf'
Plug 'preservim/tagbar'
Plug 'dhruvasagar/vim-table-mode'
Plug 'tpope/vim-markdown'
Plug 'mattn/emmet-vim'
Plug 'rust-lang/rust.vim'
Plug 'Property404/a.vim'
Plug 'tpope/vim-surround'
if has('nvim')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
call plug#end()

let g:vim_markdown_folding_disabled = 1

color wombat256grf

" Line numbers
set relativenumber
set number

" Show current match position
set shortmess-=S

" Indents
filetype plugin indent on
set autoindent
set expandtab
set ts=4 sw=4

" Wrapping
set nowrap
" Don't break in the middle of the word when wrapping
set linebreak

" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" Tags
set tags=./tags,tags;$HOME
autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/

" Buffer/Window/Split behavior
set hidden
set splitright
set splitbelow

" Tab completion
set wildignore=*.o,*.su,*.bak,*.pyc,*.elf,*.so
set wildmenu
set wildmode=longest:list,full

" Lol
command WQA wqa
command WQa wqa
command Wqa wqa
command WQ wq
command Wq wq
command W w
command Q q
command Qa qa
command QA qa
command Bn bn
command BN bn

" Disable EX mode
:map Q <Nop>

" Highlight Jenkinsfile
au BufNewFile,BufRead Jenkinsfile setf groovy

" Super scawy warning 😨 if I'm in /cmake/  directory because I'm so godddamn
" sick of losing my work
autocmd BufEnter * if expand('%:p') =~ '/cmake/.*source/' && (expand('%:p') =~ '\.c$\|\.cpp$\|\.h$\|\.hpp$') | highlight Normal ctermbg=DarkRed guibg=#8B0000 | endif
