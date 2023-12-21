alias g git
alias k kubectl
alias vim nvim
alias view 'vim -RM'
alias ls lsd
alias lla 'ls -la'
alias lt 'ls --tree'
alias lg lazygit

set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache

set -x USE_GKE_GCLOUD_AUTH_PLUGIN True

switch (uname)
case Darwin
    echo Darwin Settings!
    eval (/opt/homebrew/bin/brew shellenv)
    alias xargs gxargs
    alias head ghead
    alias tail gtail
    alias sed gsed
    alias base64 gbase64
case FreeBSD NetBSD DraqgonFly
    echo BSD Setting!
    if test -d ~/.linuxbrew
        eval ($HOME/.linuxbrew/bin/brew shellenv | source)
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv | source)
        set -x PATH $PATH $HOME/.linuxbrew/bin
    end
case '*'
    #echo Stranger!
end

fish_vi_key_bindings
set fish_plugins theme peco
function fish_user_key_bindings
    bind \cr peco_select_history
    bind \cf peco_change_directory
end

if type -q anyenv
    source (anyenv init - fish|psub)
end

if type -q starship
    starship init fish | source
end

# Added by Toolbox App
if test -d "$HOME/Library/Application Support/Jetbrains/Toolbox/scripts"
    set -x PATH $PATH "$HOME/Library/Application Support/Jetbrains/Toolbox/scripts"
end

if type -q go
    set -x PATH /usr/local/go/bin $PATH
    set -x PATH $HOME/go/bin $PATH
    set -x GO111MODULE on
end

if type -q poetry
    poetry config virtualenvs.in-project true
end

if test -d ~/.cargo
    set -x PATH $PATH $HOME/.cargo/bin
end

if test -d ~/.krew/bin
    set -x PATH $PATH $HOME/.krew/bin
end

if test -d /usr/local/kubebuilder
    set -x PATH $PATH /usr/local/kubebuilder/bin
end

if test -d $HOME/.local/bin
    set -x PATH $HOME/.local/bin $PATH
end

if type -q tty
    set -x GPG_TTY (tty)
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

#if test -z $TMUX && status --is-login
#    attach_tmux_session_if_needed
#end
