#!/bin/bash

cd `dirname $0`

echo Tune shell options && {
    set -o errexit
    set -o nounset
    set -o pipefail
}

echo Define Variables && {
    readonly PWD=$(pwd)
}

echo Setup bash && {
    ln -sf $PWD/.bashrc $HOME/.bashrc
}

echo Setup bash && {
    ln -sf $PWD/.zshrc $HOME/.zshrc
}

echo Setup fish && {
    if type fish >/dev/null 2>&1; then
        ln -sf $PWD/.config/fish/config.fish $HOME/.config/fish/config.fish
        if [ ! -d $HOME/.config/fish/functions ]; then
            mkdir -p $HOME/.config/fish/functions
        fi
        if [ ! -d $HOME/.config/fish/conf.d ]; then
            mkdir -p $HOME/.config/fish/conf.d
        fi

        for file in $(find $PWD/.config/fish/functions -maxdepth 1 -type f); do
            ln -sf $PWD/.config/fish/functions/${file##*/} $HOME/.config/fish/functions/${file##*/}
        done

        for file in $(find $PWD/.config/fish/conf.d -maxdepth 1 -type f); do
            ln -sf $PWD/.config/fish/conf.d/${file##*/} $HOME/.config/fish/conf.d/${file##*/}
        done
    else
        echo "fish does not exist in $PATH"
    fi
}

echo Setup tmux && {
    if type tmux >/dev/null 2>&1; then
        ln -sf $PWD/.tmux.conf $HOME/.tmux.conf
    else
        echo "tmux does not exist in $PATH"
    fi
}

echo Setup Jetbrains && {
    ln -sf $PWD/.ideavimrc $HOME/.ideavimrc
}

echo Setup Hyper && {
    ln -sf $PWD/.hyper.js $HOME/.hyper.js
}

echo Setup starship && {
    ln -sf $PWD/.config/starship.toml $HOME/.config/starship.toml
}

echo Setup global gitignore && {
    if [ ! -d $HOME/.config/git ]; then
        mkdir -p $HOME/.config/git
    fi
    ln -sf $PWD/.config/git/ignore $HOME/.config/git/ignore
}
