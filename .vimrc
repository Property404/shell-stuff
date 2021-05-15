" Plug plugins
call plug#begin('~/.vim/plugged')
Plug 'lifepillar/vim-mucomplete'
Plug 'majutsushi/tagbar'
Plug 'Property404/molokai-dmod'
call plug#end()

color molokai-dmod

" Line numbers
set relativenumber
set number

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
