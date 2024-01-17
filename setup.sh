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

echo Setup starship && {
    ln -sf $PWD/.config/starship.toml $HOME/.config/starship.toml
}

echo Setup global gitignore && {
    if [ ! -d $HOME/.config/git ]; then
        mkdir -p $HOME/.config/git
    fi
    ln -sf $PWD/.config/git/ignore $HOME/.config/git/ignore
}
