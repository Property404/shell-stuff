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
Plug 'vim-scripts/a.vim'
if has('nvim')
    Plug 'f-person/auto-dark-mode.nvim'
endif
call plug#end()

let g:vim_markdown_folding_disabled = 1
let g:coc_start_at_startup = v:false

if has('nvim')
    " Auto dark/light mode switching
    :lua <<EOF
    local auto_dark_mode = require('auto-dark-mode')

    auto_dark_mode.setup({
        update_interval = 10000,
        set_dark_mode = function()
            vim.api.nvim_set_option('background', 'dark')
            vim.cmd('colorscheme wombat256grf')
        end,
        set_light_mode = function()
            vim.api.nvim_set_option('background', 'light')
            vim.cmd('colorscheme morning')
        end,
    })
    auto_dark_mode.init()
EOF
else
    color wombat256grf
endif

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
