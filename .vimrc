" Install Vundle
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" mkdir -p ~/.vim/autoload ~/.vim/bundle
" curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
" Then copy this .vimrc file to your home dir
" Then run :PluginInstall in vim

" Config required for Vundle
set nocompatible              " be iMproved, required
filetype plugin indent off                  " required
syntax off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
  Plugin 'VundleVim/Vundle.vim'
  Plugin 'editorconfig/editorconfig-vim'
  Plugin 'vim-scripts/indentpython.vim'
  Plugin 'scrooloose/syntastic'
  Plugin 'nvie/vim-flake8'
  Plugin 'dikiaap/minimalist'
  Plugin 'kien/ctrlp.vim'
  Plugin 'powerline/powerline'
call vundle#end()            " required

" Now that the Vundle config is done, turn on everything that we want beyond Vundle
filetype plugin indent on    " required
syntax on

set ruler
set expandtab       " tabs are converted to spaces
set tabstop=2       " numbers of spaces of tab character
set shiftwidth=2    " numbers of spaces to (auto)indent
set softtabstop=2

set encoding=utf-8
set number
set showmatch
set autoindent
let python_highlight_all=1
filetype plugin indent on

set t_Co=256
colorscheme minimalist

highlight comment ctermfg=blue

execute pathogen#infect()

let g:syntastic_python_python_exec = '/usr/local/bin/python3'
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_loc_list_height=4
let g:syntastic_python_pylint_args="-d C0111"
let g:syntastic_python_pylint_post_args="--max-line-length=120"

let g:syntastic_enable_highlighting=1
let g:syntastic_enable_signs=1

" NERD Commenter
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1
" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" vim-javascript plugin for JSON highlighting and checking
let g:javascript_plugin_jsdoc = 1

if has('statusline')
  set laststatus=2
  " Broken down into easily includeable segments
  set statusline=%<%f\    " Filename
  set statusline+=%w%h%m%r " Options
  " set statusline+=\ [%{getcwd()}]          " current dir
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*
  let g:syntastic_enable_signs=1
  set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif

if has("autocmd")
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
