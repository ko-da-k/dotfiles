"##### dein install start #####
if &compatible
    set nocompatible
endif

let g:dein_dir = expand('~/.vim/dein')
let s:dein_repo_dir = g:dein_dir . '/repos/github.com/Shougo/dein.vim'

if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
endif

set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim

if dein#load_state(g:dein_dir)
    let s:toml = g:dein_dir . '/dein.toml'
    let s:lazy_toml = g:dein_dir . '/dein_lazy.toml'

    call dein#begin(expand('~/.vim/dein'), [$MYVIMRC,s:toml])

    " TOMLファイルにpluginを記述
    call dein#load_toml(s:toml, {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})

    call dein#end()
    call dein#save_state()
endif

" check installation
if dein#check_install()
    call dein#install()
endif
"##### dein install finished #####

"#####kaoriya#####
if has('kaoriya')
    set noundofile
    let g:no_vimrc_example=0
    let g:vimrc_local_finish=1
    let g:gvimrc_local_finish=1

    "$VIM/plugins/kaoriya/autodate.vim
    let plugin_autodate_disable  = 1
    "$VIM/plugins/kaoriya/cmdex.vim
    let plugin_cmdex_disable     = 1
    "$VIM/plugins/kaoriya/dicwin.vim
    let plugin_dicwin_disable    = 1
    "$VIMRUNTIME/plugin/format.vim
    let plugin_format_disable    = 1
    "$VIM/plugins/kaoriya/hz_ja.vim
    let plugin_hz_ja_disable     = 1
    "$VIM/plugins/kaoriya/scrnmode.vim
    let plugin_scrnmode_disable  = 1
    "$VIM/plugins/kaoriya/verifyenc.vim
    let plugin_verifyenc_disable = 1
endif

"##### common setup #####
set encoding=UTF-8
filetype plugin indent on
filetype plugin on
syntax on
colorscheme dracula
let g:dracula_colorterm = 0
let g:dracula_italic = 0
set termguicolors
set autoindent "新しい行のインデントを現在行と同じにする
set expandtab "タブで挿入する文字をスペースに
set number "行番号を表示する
set title "編集中のファイル名を表示
"set cursorline "カーソルのある行にアンダーラインを引く
set showmatch "括弧入力時の対応する括弧を表示
set tabstop=4 "インデントをスペース4つ分に設定
set shiftwidth=4 "自動インデントの幅
set smartindent "オートインデント
set smarttab "新しい行を作った時に高度な自動インデント
set clipboard=unnamed,autoselect "OSのクリッポボードと連携
set matchpairs& matchpairs+=<:> "対応カッコに＜＞を追加
set backspace=eol,indent,start
"## file setting
set noswapfile "スワップファイルを作らない
set nobackup "バックアップを作成しない
set viminfo= "viminfoを作成しない
"##### common setup end #####

"##### keybind start #####
source ~/.vimrc.keymap 

"### Unite.vim
nnoremap [unite] <Nop>
nmap <Space>f [unite]
nnoremap <silent> [unite]f :Unite<Space>file<CR>
nnoremap <silent> [unite]n :Unite<Space>file/new<CR>

"##### keybind end ##### 
