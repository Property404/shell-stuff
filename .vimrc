" Plug plugins
call plug#begin('~/.vim/plugged')
Plug 'lifepillar/vim-mucomplete'
Plug 'gryf/wombat256grf'
Plug 'preservim/tagbar'
Plug 'dhruvasagar/vim-table-mode'
Plug 'plasticboy/vim-markdown'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mattn/emmet-vim'
Plug 'rust-lang/rust.vim'
Plug 'zntfdr/Christmas'
call plug#end()

let g:vim_markdown_folding_disabled = 1

color wombat256grf
" Enable this during Christmas time
"color Christmas

" Line numbers
set relativenumber
set number

" Show current match position
set shortmess-=S

" Indents
set cindent
set ts=4 sw=4
set nowrap
set expandtab
set shiftwidth=4
set autoindent
set smartindent

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

" Highlight Jenkinsfile
au BufNewFile,BufRead Jenkinsfile setf groovy
