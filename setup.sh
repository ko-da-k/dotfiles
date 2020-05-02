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

echo Setup fish && {
    if type -a fish >/dev/null 2>&1; then
        ln -sf $PWD.config/fish.config.fish $HOME/.config/fish/config.fish
        ln -sf $PWD.config/fish/functions/fish_prompt.fish $HOME/.config/fish/functions/fish_prompt.fish
        ln -sf $PWD.config/fish/conf.d/dracula.fish $HOME/.config/fish/conf.d/dracula.fish
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

echo Setup vim && {
    if type vim >/dev/null 2>&1; then
        ln -sf $PWD/.vimrc $HOME/.vimrc
        ln -sf $PWD/.ideavimrc $HOME/.ideavimrc

        mkdir -p $HOME/.vim/after/ 2>/dev/null
        mkdir -p $HOME/.vim/after/ftplugin 2>/dev/null

        for file in $(find $PWD/.vim/after/ftplugin -maxdepth 1 -type f); do
            ln -sf $PWD/.vim/after/ftplugin/${file##*/} $HOME/.vim/after/ftplugin/${file##*/}
        done

        # setup dein
        ln -sf $PWD/vim/dein/dein.toml $HOME/.vim/dein/dein.toml
        ln -sf $PWD/vim/dein/dein_lazy.tom/ $HOME/.vim/dein/dein_lazy.toml
    else
        echo "vim does not exist in $PATH"
    fi
}

echo Setup Jetbrains && {
    ln -sf $PWD/.ideavimrc $HOME/.ideavimrc
}

echo Install Ansible && {
    if type ansible >/dev/null 2>&1; then
        echo "ansible is already installed" 
    else
        OS_TYPE=$(uname -s) 
        if [ $OS_TYPE == "Darwin" ]; then
            echo "for Darwin"
            if type brew >/dev/null 2>&1; then
                brew install ansible
            else
                echo "brew not found. please install homebrew"
            fi
        elif [ $OS_TYPE == "Linux" ]; then
            echo "for Linux"
            if  [ -e /etc/debian_version ] || [ -e /etc/debian_release ]; then
                if [ -e /etc/lsb-release ]; then
                    echo "Ubuntu Distribution"
                    sudo sh -c "apt update"
                    sudo sh -c "apt install software-properties-common"
                    sudo sh -c "apt-add-repository --yes --update ppa:ansible/ansible"
                    sudo sh -c "apt install ansible -y"
                else
                    echo "Debian Distribution"
                    echo "ansible cannot be installed automatically."
                fi
            else
                echo "unsupported distribution. skip installation."
            fi
        else
            echo "it does not support $OS_TYPE. skip installation."
        fi
    fi
}
