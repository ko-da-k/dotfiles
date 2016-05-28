"#####deinの設定#####
if &compatible
  set nocompatible
endif
set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim

if dein#load_state(expand('~/.vim/dein'))
    call dein#begin(expand('~/.vim/dein'))

    " プラグインリストを収めたTOMLファイル
    let g:dein_dir = expand('~/.vim/dein')
    let s:toml = g:dein_dir . '/dein.toml'
    let s:lazy_toml = g:dein_dir . '/dein_lazy.toml'

    " TOMLファイルにpluginを記述
    call dein#load_toml(s:toml, {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})

    call dein#end()
    call dein#save_state()
endif

" 未インストールを確認
if dein#check_install()
    call dein#install()
endif

filetype plugin indent on

"#####初期設定#####
syntax on "コードの色分け
"#####表示設定#####
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
set colorcolumn=80 "80行目にラインを入れる
set backspace=eol,indent,start

"#####キーバインド#####
inoremap <Space>j <Esc> 
noremap <Space>o o<Esc>
noremap <Space>p o<Esc>p
noremap <Space>h ^
noremap <Space>l $

"#####余計なファイル設定#####
set noswapfile "スワップファイルを作らない
set nobackup "バックアップを作成しない
set viminfo= "viminfoを作成しない

"#####検索設定#####
set ignorecase "大文字/小文字の区別なく検索する
set smartcase "検索文字列に大文字が含まれている場合は区別して検索する
set wrapscan "検索時に最後まで行ったら最初に戻る
