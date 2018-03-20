set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" $ git submodule init
" $ git submodule update
" $ BundleInstall [in vim]
Bundle 'gmarik/vundle'
Plugin 'fatih/vim-go'
Bundle 'tpope/vim-sensible'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-fugitive'
"Bundle 'tpope/vim-rails'
"Bundle 'tpope/vim-rake'
"Bundle 'nanotech/jellybeans.vim'
Bundle 'Lokaltog/vim-powerline'
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdtree'
Bundle 'kien/ctrlp.vim'
Bundle 'majutsushi/tagbar'
Bundle 'lervag/vimtex'
"Plugin 'marcopaganini/termschool-vim-theme'
Plugin 'rafi/awesome-vim-colorschemes'

"Bundle 'rking/ag.vim'
"Bundle 'kana/vim-textobj-user'
"Bundle 'nelstrom/vim-textobj-rubyblock'
"Bundle 'slim-template/vim-slim'

" ...

filetype plugin indent on     " required!
set background=dark
set wrapmargin=8

set mouse=a

syntax on
set ruler

" size of a hard tabstop
set tabstop=4

" size of an "indent"
set shiftwidth=4

" a combination of spaces and tabs are used to simulate tab stops at a width
" other than the (hard)tabstop
set softtabstop=4

" make "tab" insert indents instead of tabs at the beginning of a line
set smarttab

" always uses spaces instead of tab characters
set expandtab
set listchars=tab:\ \ ,trail:.

set cursorline

" Backups and swap
set nobackup
set nowritebackup
set noswapfile
set backupdir=~/.vim/backup
set directory=~/.vim/backup
set nohidden
set history=10000
" set number
set ruler
set switchbuf=useopen
set clipboard=unnamedplus

if (&t_Co == 256)
    "colorscheme jellybeans
    colorscheme termschool
endif

highlight ExtraWhitespace ctermbg=darkred guibg=darkred
match ExtraWhitespace /\s\+$/

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" key mapping for window navigation
"
" If you're in tmux it'll keep going to tmux splits if you hit the end of
" your vim splits.
"
" For the tmux side see:
" https://github.com/aaronjensen/dotfiles/blob/e9c3551b40c43264ac2cd21d577f948192a46aea/tmux.conf#L96-L102
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if exists('$TMUX')
    function! TmuxOrSplitSwitch(wincmd, tmuxdir)
        let previous_winnr = winnr()
        execute "wincmd " . a:wincmd
        if previous_winnr == winnr()
            " The sleep and & gives time to get back to vim so tmux's focus tracking
            " can kick in and send us our ^[[O
            execute "silent !sh -c 'sleep 0.01; tmux select-pane -" . a:tmuxdir . "' &"
            redraw!
        endif
    endfunction

    let previous_title = substitute(system("tmux display-message -p '#{pane_title}'"), '\n', '', '')
    let &t_ti = "\<Esc>]2;vim\<Esc>\\" . &t_ti
    let &t_te = "\<Esc>]2;". previous_title . "\<Esc>\\" . &t_te

    nnoremap <silent> <C-h> :call TmuxOrSplitSwitch('h', 'L')<cr>
    nnoremap <silent> <C-j> :call TmuxOrSplitSwitch('j', 'D')<cr>
    nnoremap <silent> <C-k> :call TmuxOrSplitSwitch('k', 'U')<cr>
    nnoremap <silent> <C-l> :call TmuxOrSplitSwitch('l', 'R')<cr>
else
    map <C-h> <C-w>h
    map <C-j> <C-w>j
    map <C-k> <C-w>k
    map <C-l> <C-w>l
endif

" Strip trailing whitespace.
" http://vim.wikia.com/wiki/Remove_unwanted_spaces
command! Strip let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl

" http://snk.tuxfamily.org/log/vim-256color-bce.html
" Disable Background Color Erase (BCE) so that color schemes
" work properly when Vim is used inside tmux and GNU screen.
if &term =~ '256color'
    set t_ut=
endif

" Filetype actions {
    if has("autocmd")
        autocmd BufNewFile,BufRead *.pro,*.pri  set filetype=qmake
        autocmd BufNewFile,BufRead *.qml,*.qmlproject set filetype=qml
    endif
" }

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:vimtex_disable_version_warning = 1

let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1

hi  goSameId term=reverse ctermfg=7 ctermbg=3 guifg=#000000 guibg=#ce5c00
let g:go_auto_sameids = 1

"let g:go_fmt_command = "goimports"

au FileType go nmap <F8> <Plug>(go-metalinter)
let g:go_metalinter_deadline = "5s"

let g:go_metalinter_enabled = [
    \ 'deadcode',
    \ 'errcheck',
    \ 'gas',
    \ 'goconst',
    \ 'gocyclo',
    \ 'golint',
    \ 'gosimple',
    \ 'ineffassign',
    \ 'vet',
    \ 'vetshadow'
\]
set rtp+=$GOPATH/src/github.com/golang/lint/misc/vim
let g:ycm_server_python_interpreter = '/usr/bin/python2'
let g:ycm_global_ycm_extra_conf = '/usr/share/vim/vimfiles/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
"let g:ycm_server_keep_logfiles = 1
"let g:ycm_server_log_level = 'debug'
"
let g:airline_powerline_fonts=1
let g:Powerline_symbols = 'unicode'
let g:powerline_pycmd = "py3"

