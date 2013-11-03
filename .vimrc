set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" $ git submodule init
" $ git submodule update
" $ BundleInstall [in vim]
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github

" To compile the required module, after BundleInstall:
" $ cmake -G "Unix Makefiles" -DUSE_SYSTEM_LIBCLANG=ON . ~/.vim/bundle/YouCompleteMe/cpp
" $ make ycm_core
Bundle 'Valloric/YouCompleteMe'

"Easy tags
Bundle 'xolox/vim-misc'
Bundle 'xolox/vim-easytags'

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
    colorscheme jellybeans
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

" EasyTags config
let g:easytags_file = '~/.vim/tags'
let g:easytags_autorecurse = 0
let g:easytags_include_members = 1
let g:easytags_resolve_links = 1
let g:easytags_updatetime_warn = 0 " Disable ctags updatetime warnings
let g:easytags_auto_highlight = 0

