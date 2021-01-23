alias g git
alias k kubectl
alias vim nvim

switch (uname)
case Linux
    echo Linux Settings!
    set -x PATH $HOME/.local/bin $PATH
case Darwin
    echo Darwin Settings!
    alias xargs gxargs
    alias head ghead
    alias tail gtail
    alias sed gsed
    alias base64 gbase64
case FreeBSD NetBSD DraqgonFly
    echo BSD Setting!
case '*'
    echo Stranger!
end

fish_vi_key_bindings
set fish_plugins theme peco
function fish_user_key_bindings
    bind \cr peco_select_history
    bind \cf peco_change_directory
end

if test -d ~/.pyenv
    set -x PYENV_ROOT $HOME/.pyenv
    if test -d ~/.pyenv/bin
        set -x PATH $PATH $PYENV_ROOT/bin 
    end
    eval (pyenv init - | source)
end
set -x PIPENV_VENV_IN_PROJECT true

if test -d ~/.linuxbrew
    eval ($HOME/.linuxbrew/bin/brew shellenv | source)
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv | source)
    set -x PATH $PATH $HOME/.linuxbrew/bin
end

set -x GOPATH $HOME/go
set -x PATH /usr/local/go/bin $PATH
if test -d $GOPATH/bin
    set -x PATH $PATH $GOPATH/bin
end
set -x PATH $GOROOT/bin $PATH
set -x GO111MODULE on

if test -d ~/.cargo
    set -x PATH $PATH $HOME/.cargo/bin
end

if test -d /usr/local/kubebuilder
    set -x PATH $PATH /usr/local/kubebuilder/bin
end

if type -q starship
    starship init fish | source
end

export LSCOLORS=gxfxcxdxbxegedabagacad
