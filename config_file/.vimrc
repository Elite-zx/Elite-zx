"====================================================basic settings==========================================
"show line number
set nu
set rnu
syntax enable
set t_Co=256
set termguicolors
" line
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

" Move the cursor to a position where there are no characters
set virtualedit=block

"set mouse=a
set smartindent

" Ignore case when searching
set ignorecase
set smartcase

set background=dark

set t_RV=

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

" ctags
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
Plug 'jiangmiao/auto-pairs'
Plug 'bfrg/vim-cpp-modern'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'liuchengxu/vista.vim'
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
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'tpope/vim-surround'
Plug 'vim-autoformat/vim-autoformat'
Plug 'liuchengxu/vim-which-key'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-repeat'
Plug 'morhetz/gruvbox'
Plug 'ajmwagar/vim-deus'
Plug 'machakann/vim-highlightedyank'
Plug 'voldikss/vim-floaterm'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

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
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 1
let verbose=1
au BufWrite * :Autoformat

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDCommenter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Create default mappings
let g:NERDCreateDefaultMappings = 1

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 0

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/*','right': '*/' },'cpp': { 'left': '/*','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-which-key
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <silent> <leader> :WhichKey ','<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-repeat
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vista
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <F8> :Vista!!<CR>
let g:vista#renderer#enable_icon = 1
let g:vista_icon_indent =  ["╰─▸ ", "├─▸ "]
let g:vista_sidebar_width =40
let g:vista_fzf_preview = ['right:50%']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LeaderF
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" popup mode
let g:Lf_PreviewInPopup = 1
let g:Lf_PreviewHorizontalPosition = 'right'
let g:Lf_WindowPosition = 'popup'
let g:Lf_StlSeparator = { 'left': "\ueb0", 'right': "\ue0b2", 'font': "Monaco Nerd Font Mono" }
let g:Lf_PreviewResult = {'File':1,'Rg':1,'Function': 0, 'BufTag': 0 }
let g:Lf_ShortcutF ='<leader>f'
let g:Lf_ShowDevIcons = 1
let g:Lf_GtagsAutoGenerate = 1
let g:Lf_Gtagslabel = 'native-pygments'
" let g:Lf_ReverseOrder = 1

nmap <Leader>r  :Leaderf rg<CR>
nmap <Leader>g :Leaderf gtags<CR>
nmap <C-]> :Leaderf gtags --by-context --auto-jump<CR>



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-highlightedyank
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:highlightedyank_highlight_in_visual = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cpp-enhanced-highlight
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:cpp_stl_container_highlight = 1
" let g:cpp_stl_algorithm_highlight = 1
" let g:cpp_stl_iterator_highlight = 1
" let g:cpp_class_scope_highlight = 1
" let g:cpp_member_variable_highlight = 1
" let g:cpp_class_decl_highlight = 1
" let g:cpp_posix_standard = 1
" let g:cpp_experimental_simple_template_highlight = 1
" let c_no_curly_error=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-cpp-modern
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable highlighting of C++11 attributes
let g:cpp_attributes_highlight = 1

" Highlight struct/class member variables (affects both C and C++ files)
let g:cpp_member_highlight = 1

" Put all standard C and C++ keywords under Vim's highlight group 'Statement'
" (affects both C and C++ files)
let g:cpp_simple_highlight = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" colorscheme dracula
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
colorscheme dracula

let g:dracula_italic = 1
let g:dracula_bold = 1


"italic for comments
highlight DraculaComment cterm=italic gui=italic

"
" autocmd vimenter * colorscheme dracula

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
let g:airline_theme='dracula'
" let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

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
let g:gutentags_project_root = ['.git', '.root', '.svn', '.hg', '.project']
let g:gutentags_ctags_tagfile = '.tags'

let g:gutentags_modules = []
if executable('ctags')
	let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
	let g:gutentags_modules += ['gtags_cscope']
endif

let g:gutentags_cache_dir = expand('~/.cache/tags')

let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
let g:gutentags_auto_add_gtags_cscope = 0

" gtags
let $GTAGSFORCECPP = 1
let $GTAGSLABEL = 'native-pygments'

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
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

let g:coc_snippet_next = '<Tab>'

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
" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-floaterm
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:floaterm_keymap_toggle = '<F12>'
let g:floaterm_keymap_kill = '<F9>'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-startify
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:startify_custom_header = [
\'  __  __ _   _  _   _  __     __ ___  __  __   ',
\'  \ \/ /| | | || \ | | \ \   / /|_ _||  \/  |  ',
\'   \  / | | | ||  \| |  \ \ / /  | | | |\/| |  ',
\'   /  \ | |_| || |\  |   \ V /   | | | |  | |  ',
\'  /_/\_\ \___/ |_| \_|    \_/   |___||_|  |_|  ',
      \ ]



"==============================================keys customiztion && function ====================================

" disable arrow keys
"map <Left> <Nop>
"map <Right> <Nop>
"map <Up> <Nop>
"map <Down> <Nop>

" disable F1
nmap <F1> <nop>
imap <F1> <nop>
cmap <F1> <nop>

" press ctrl-c fast to trigger Esc in insert mode
imap <C-c> <Esc>


" nnoremap <C-i> :PlugInstall<CR>
" nnoremap <C-l> :IndentLinesToggle<CR>
"nmap <C-s> <Plug>MarkdownPreviewToggle

" quickly insert an empty new line without leaving normal mode
nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>

nnoremap k kzz
nnoremap j jzz
"  Set 8 lines to the cursor - when moving vertically using j/k
"set so=8

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

map ]b :bnext<CR>
map [b :bprevious<CR>
map ]t :tabnext<CR>
map [t :tabprevious<CR>


" copy and paste
vmap <C-c> "+yi
vmap <C-x> "+c
vmap <C-v> c<ESC>"+p

" yank a line without newline
vnoremap al :<C-U>normal 0v$h<CR>
omap al :normal val<CR>
vnoremap il :<C-U>normal ^vg_<CR>
omap il :normal vil<CR>
