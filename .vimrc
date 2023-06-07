call plug#begin()

Plug 'preservim/nerdtree'
Plug 'jiangmiao/auto-pairs'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'rakr/vim-one'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'Yggdroot/indentLine'
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'luochen1990/rainbow'
Plug 'rhysd/vim-clang-format'
Plug 'mhinz/vim-startify'
Plug 'github/copilot.vim'
Plug 'voldikss/vim-translator'

call plug#end()

" NERDTree
:let g:NERDTreeWinSize=20
"LeaderF
let g:Lf_PreviewInPopup = 1   
let g:Lf_WindowPosition = 'popup'
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0 }
let g:Lf_ShortcutF = '<C-P>'
let g:Lf_ShowDevIcons = 0
"clang-format
let g:clang_format#auto_format = 1
let g:clang_format#auto_filetypes= ["c", "cpp", "objc", "java"]
" cpp-enhanced-highlight
let g:cpp_stl_container_highlight = 1
let g:cpp_stl_algorithm_highlight = 1
let g:cpp_stl_iterator_highlight = 1
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_simple_template_highlight = 1
let c_no_curly_error=1
" vim-one colortheme
colorscheme one
set background=dark       " for the dark version
let g:one_allow_italics = 1 " I love italic for comments
" rainbow  
let g:rainbow_active = 1 
" vim translator
let g:translator_default_engines = 'google'
" airline
let g:airline_theme='deus'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_extensions = []
"indentLine
let g:indent_guides_guide_size = 1  
let g:indent_guides_start_level = 2  
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
" Mapping keyboard shortcuts for commands
nnoremap <C-i> :PlugInstall<CR>
nnoremap <C-l> :IndentLinesToggle<CR>
nnoremap <leader>w :tabclose<CR>
nnoremap <leader>t :NERDTreeToggle<CR> 
" basic settings
set nu  "show line
syntax enable
set t_Co=256
set termguicolors
set cursorline  " highlight current line
filetype plugin indent on
filetype on
" vertical show commandline
set wildmenu
set wildoptions=pum  

map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
set smarttab
set shiftwidth=4
set tabstop=4
set expandtab
"set mouse=a
set smartindent
set ruler
set sm!
" effect backspace
set backspace=indent,eol,start 
set hlsearch
set incsearch
set showmatch
set showcmd
set ai
set si
set cindent
set clipboard+=unnamed
set tags=tags;
" quick escape to normal mode
set ttimeoutlen=50  
" Automatically select after adjusting the indentation
vnoremap < <gv   
vnoremap > >gv
" highlight current line but no in insert mode
autocmd InsertLeave,WinEnter * set cursorline 
autocmd InsertEnter,WinLeave * set nocursorline
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