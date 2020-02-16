#!/bin/bash

set -o xtrace

cd `dirname $0`


# setup fish
ln -sf `pwd`/config.fish ~/.config/fish/config.fish
ln -sf `pwd`/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish
ln -sf `pwd`/dracula.fish ~/.config/fish/conf.d/dracula.fish

# setup tmux
ln -sf `pwd`/tmux.conf ~/.tmux.conf

# setup vim
ln -sf `pwd`/vimrc ~/.vimrc
ln -sf `pwd`/ideavimrc ~/.ideavimrc

mkdir -p ~/.vim/after/ 2>/dev/null
mkdir -p ~/.vim/after/ftplugin 2>/dev/null

PWD = `pwd`
for file in `find $PWD/.vim/after/ftplugin -maxdepth 1 -type f`; do
    ln -sf $PWD/.vim/after/ftplugin/${file##*/} ~/.vim/after/ftplugin/${file##*/}
done

# setup dein
ln -sf `pwd`/vim/dein/dein.toml ~/.vim/dein/dein.toml
ln -sf `pwd`/vim/dein/dein_lazy.tom/ ~/.vim/dein/dein_lazy.toml
