" Plug plugins
call plug#begin('~/.vim/plugged')
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
call plug#end()

" Deoplete settings
let g:deoplete#enable_at_startup =1
call deoplete#custom#option('auto_complete_delay', 100)

" Line numbers
set relativenumber
set number

" Indents
set cindent
set copyindent
set ts=4 sw=4
set nowrap

" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" Tags
set tags=./tags,tags;$HOME

" Always use directory of file as current directory
" set autochdir

" Buffer/Window/Split behavior
set hidden
set splitright
set splitbelow

" Tab completion
set wildignore=*.o,*.su,*.bak,*.pyc,*.elf,*.so
set wildmenu
set wildmode=longest:list,full
