call plug#begin('~/.local/share/nvim/plugged')
  Plug 'phanviet/vim-monokai-pro'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'pangloss/vim-javascript'
  Plug 'mxw/vim-jsx'
  Plug 'scrooloose/nerdtree'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'dense-analysis/ale'
  Plug 'jremmen/vim-ripgrep'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'neoclide/coc-tsserver'
  Plug 'easymotion/vim-easymotion'
  Plug 'vim-python/python-syntax'
  Plug 'leafgarland/typescript-vim'
  Plug 'peitalin/vim-jsx-typescript'
  Plug 'jparise/vim-graphql'
  Plug 'mhartington/nvim-typescript', {'do': './install.sh'}
  Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
call plug#end()

set nobackup
set nowritebackup
set clipboard=unnamedplus
set relativenumber
set background=dark
set termguicolors
colorscheme monokai_pro
" ctrl p
let g:ctrlp_use_caching = 0
" Fugitive (oneline)
set statusline+=%{fugitive#statusline()}
let g:mta_use_matchparen_group = 1
" Eslint
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['tsserver', 'tslint']
\}

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['prettier', 'eslint'],
\   'typescript': ['prettier', 'tslint']
\}
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
let g:ale_fix_on_save = 1
"Multiple cursors
let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_start_word_key      = '<C-d>'
let g:multi_cursor_select_all_word_key = '<A-n>'
let g:multi_cursor_start_key           = 'g<C-d>'
let g:multi_cursor_select_all_key      = 'g<A-n>'
let g:multi_cursor_next_key            = '<C-d>'
let g:multi_cursor_prev_key            = '<C-s>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

"Ctrl-P
set wildignore+=*/node_modules/*,*/coverage/*,*/bower_components/*,*.so,*.swp,*.zip

function! GrepInput()
  call inputsave()
  let pattern = input('Pattern: ')
  call inputrestore()
  execute 'Rg -i -S --vimgrep '.pattern
endfunction

nnoremap <C-F> :call GrepInput()<CR>
"Tabs
nnoremap <A-h> :tabprevious<CR>
nnoremap <A-l> :tabnext<CR>
nnoremap <A-k> :tabclose<CR>
nnoremap <A-1> 1gt
nnoremap <A-2> 2gt
nnoremap <A-3> 3gt
nnoremap <A-4> 4gt
nnoremap <A-5> 5gt
nnoremap <A-6> 6gt
nnoremap <A-7> 7gt
nnoremap <A-8> 8gt
nnoremap <A-9> 9gt
nnoremap <A-0> :tablast<CR>

nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l
" Nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

map <C-n> :NERDTreeToggle<CR>
map <A-r> :NERDTreeFind<cr>
let g:NERDTreeWinPos = "left"
let NERDTreeShowHidden=1

" TabDTreeAutoCenter=0
set tabstop=2
set shiftwidth=2
set expandtab
" Autocomplete
" let g:deoplete#enable_at_startup = 1
" let g:deoplete#sources#ternjs#types = 1
" Dart
let dart_html_in_string=v:true
let dart_style_guide = 2
let dart_format_on_save = 1

" easymotion

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
map <Leader> <Plug>(easymotion-prefix)
" Turn on case-insensitive feature
nmap <Leader>s <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
nmap <Leader>l <Plug>(easymotion-overwin-line)

" cwce
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" coc ts
nmap <silent> \gd :vsplit<CR><Plug>(coc-definition)

" python
let g:python_highlight_all = 1
