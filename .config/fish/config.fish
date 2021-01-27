alias g git
alias k kubectl
alias vim nvim
alias ls lsd
alias lla 'ls -la'
alias lt 'ls --tree'
alias lg lazygit

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

function attach_tmux_session_if_needed
    set ID (tmux list-sessions)
    if test -z "$ID"
        tmux new-session
        return
    end

    set new_session "Create New Session" 
    set ID (echo $ID\n$new_session | peco --on-cancel=error | cut -d: -f1)
    if test "$ID" = "$new_session"
        tmux new-session
    else if test -n "$ID"
        tmux attach-session -t "$ID"
    end
end

if test -z $TMUX && status --is-login
    attach_tmux_session_if_needed
end
