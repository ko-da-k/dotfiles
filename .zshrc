


# 環境変数
export LANG=ja_JP.UTF-8

# 色を使用できるようにする
autoload -Uz colors
colors

# vim風キーバインド
bindkey -v

# ヒストリを増やす
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 直前と同じコマンドの場合は履歴に追加しない
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存する時に余分なスペースを削除
setopt hist_reduce_blanks

# 自動補完
autoload -U compinit; compinit

# cd省略
setopt auto_cd

# cdしたディレクトリをスタックに保存
# cd+<tab>でディレクトリの履歴が出る
setopt auto_pushd

# pushdしたとき、ディレクトリがすでにスタックに含まれていれば追加しない
setopt pushd_ignore_dups

# 候補を詰めて表示
setopt list_packed

# prompt
PROMPT="%{${fg[green]}%}%n%{${reset_color}%}@%{${fg[cyan]}%}%m%{${reset_color}%}:%{${fg[yellow]}%}[%~]
%{${reset_color}%}%# "
