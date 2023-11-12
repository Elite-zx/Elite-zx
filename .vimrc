"====================================================basic settings==========================================
"show line number
set nu
set rnu
syntax enable
set t_Co=256
set termguicolors
" highlight current line
set cursorline
filetype plugin indent on
filetype on

set wildmenu
set wildmode=longest:full,full

set encoding=utf-8
"set fileencoding=utf-8
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8

" google-style indent for C++
set smarttab
set shiftwidth=2
set tabstop=2
set expandtab

" A buffer becomes hidden when it is abandoned
set hid

"set mouse=a
set smartindent

" Ignore case when searching
set ignorecase
set smartcase

set background=dark

set ruler
set sm!
" effect backspace
set backspace=indent,eol,start

set hlsearch
" Matches are gradually displayed.
set incsearch

set showmatch
set showcmd
" autoindent
set ai
" smartindent
set si
set cindent
set clipboard+=unnamed
set tags=./.tags;,.tags
" quick escape to normal mode
set ttimeoutlen=50

set autowrite
set autoread

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=

" ==========================================plugin config==================================================
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'jiangmiao/auto-pairs'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'rakr/vim-one'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'Yggdroot/indentLine'
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'luochen1990/rainbow'
Plug 'mhinz/vim-startify'
Plug 'github/copilot.vim'
Plug 'voldikss/vim-translator'
Plug 'preservim/nerdcommenter'
Plug 'godlygeek/tabular'
Plug 'ryanoasis/vim-devicons'
Plug 'romainl/vim-cool'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'vim-utils/vim-man'
Plug 'pboettch/vim-cmake-syntax'
Plug 'ludovicchabant/vim-gutentags'
Plug 'preservim/tagbar'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'tpope/vim-surround'
Plug 'vim-autoformat/vim-autoformat'
Plug 'liuchengxu/vim-which-key'
"Plug 'preservim/vim-markdown'
"Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

call plug#end()

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","

"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:NERDTreeWinPos = "left"
let NERDTreeShowHidden=0
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize=24
map <leader>nn :NERDTreeToggle<cr>
map <leader>nf :NERDTreeFind<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autoformat
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufWrite * :Autoformat

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-which-key
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <silent> <leader> :WhichKey ','<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tagbar
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <F8> :TagbarToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LeaderF
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:Lf_PreviewInPopup = 1
let g:Lf_WindowPosition = 'popup'
let g:Lf_StlSeparator = { 'left': "\ueb0", 'right': "\ue0b2", 'font': "Monaco Nerd Font Mono" }
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0 }
let g:Lf_ShortcutF = '<C-P>'
let g:Lf_ShowDevIcons = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cpp-enhanced-highlight
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:cpp_stl_container_highlight = 1
let g:cpp_stl_algorithm_highlight = 1
let g:cpp_stl_iterator_highlight = 1
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_simple_template_highlight = 1
let c_no_curly_error=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" colortheme
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
colorscheme dracula

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tagbar
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <F8> :TagbarToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cpp-enhanced-highlight
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:cpp_stl_container_highlight = 1
let g:cpp_stl_algorithm_highlight = 1
let g:cpp_stl_iterator_highlight = 1
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_simple_template_highlight = 1
let c_no_curly_error=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" colortheme
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
colorscheme dracula

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" rainbow
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:rainbow_active=1
" remove brackets in nerdtree
"let g:rainbow_active=0
"autocmd FileType * let g:rainbow_active=1
" disable rainbow in cmake to make cmake syntax highlight
let g:rainbow_conf = {
      \   'separately': {
      \       'cmake': 0,
      \   }
      \}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" airline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline_theme='deus'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_extensions = []

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" indentLine
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-markdown/preview
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let g:vim_markdown_math = 1 "enable latex
"let g:mkdp_browser = '/opt/google/chrome/google-chrome'
"let g:mkdp_open_ip = 'localhost:8080'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-gutentags
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
let g:gutentags_ctags_tagfile = '.tags'
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
if !isdirectory(s:vim_tags)
  silent! call mkdir(s:vim_tags, 'p')
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-cool
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:cool_total_matches = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" coc-nvim config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" use <tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-startify
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:startify_custom_header = [
      \ '                                ',
      \ '            __                  ',
      \ '    __  __ /\_\    ___ ___      ',
      \ '   /\ \/\ \\/\ \ /'' __` __`\   ',
      \ '   \ \ \_/ |\ \ \/\ \/\ \/\ \   ',
      \ '    \ \___/  \ \_\ \_\ \_\ \_\  ',
      \ '     \/__/    \/_/\/_/\/_/\/_/  ',
      \ ]
<


"==============================================keys customiztion && function ====================================

" disable arrow keys
"map <Left> <Nop>
"map <Right> <Nop>
"map <Up> <Nop>
"map <Down> <Nop>

" Mapping keyboard shortcuts for commands
nnoremap <C-i> :PlugInstall<CR>
nnoremap <C-l> :IndentLinesToggle<CR>
"nmap <C-s> <Plug>MarkdownPreviewToggle

"nnoremap k kzz
"nnoremap j jzz
"  Set 8 lines to the cursor - when moving vertically using j/k
set so=8

" Automatically select after adjusting the indentation
vnoremap < <gv
vnoremap > >gv

" highlight current line but no in insert mode
autocmd InsertLeave,WinEnter * set cursorline
autocmd InsertEnter,WinLeave * set nocursorline

"italic for comments
highlight Comment cterm=italic gui=italic
" change cursor shape in between insert mode and normal/visual mode
if has("autocmd")
  au VimEnter,InsertLeave * silent execute '!echo -ne "\e[2 q"' | redraw!
  au InsertEnter,InsertChange *
        \ if v:insertmode == 'i' |
        \   silent execute '!echo -ne "\e[6 q"' | redraw! |
        \ elseif v:insertmode == 'r' |
        \   silent execute '!echo -ne "\e[4 q"' | redraw! |
        \ endif
  au VimLeave * silent execute '!echo -ne "\e[ q"' | redraw!
endif

" syntax highlight for assembly
autocmd BufNewFile,BufRead *.s set filetype=nasm
autocmd BufNewFile,BufRead *.S set filetype=nasm
autocmd BufNewFile,BufRead *.asm set filetype=nasm

" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>
function! VisualSelection(direction, extra_filter) range
  let l:saved_reg = @"
  execute "normal! vgvy"

  let l:pattern = escape(@", "\\/.*'$^~[]")
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  if a:direction == 'gv'
    call CmdLine("Ack '" . l:pattern . "' " )
  elseif a:direction == 'replace'
    call CmdLine("%s" . '/'. l:pattern . '/')
  endif

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove


" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Let '\tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()


