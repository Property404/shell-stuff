" Plug plugins
call plug#begin('~/.vim/plugged')
Plug 'lifepillar/vim-mucomplete'
Plug 'gryf/wombat256grf'
" Plug 'preservim/tagbar'
" Plug 'dhruvasagar/vim-table-mode'
" Plug 'aliou/bats.vim'
call plug#end()

color wombat256grf

" Line numbers
set relativenumber
set number

" Show current match position
set shortmess-=S

" Indents
set cindent
set copyindent
set ts=4 sw=4
set nowrap
set expandtab

" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" Tags
set tags=./tags,tags;$HOME

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

" Disable EX mode
:map Q <Nop>
