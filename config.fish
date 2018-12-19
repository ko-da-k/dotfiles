alias g gcloud
alias k kubectl

set fish_plugins theme peco

if test -d ~/.pyenv
  set -x PYENV_ROOT $HOME/.pyenv
  if test -d ~/.pyenv/bin
    set -x PATH $PYENV_ROOT/bin $PATH
  end
  eval (pyenv init - | source)
end

if test -d ~/.nodebrew
  set -x PATH $HOME/.nodebrew/current/bin $PATH
end

if test -d ~/.linuxbrew
  eval ($HOME/.linuxbrew/bin/brew shellenv | source)
  eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv | source)
  set -x PATH $HOME/.linuxbrew/bin $PATH
end

set -x GOROOT /usr/local/opt/go/libexec
set -x GOPATH $HOME/go
if test -d $GOPATH/bin
  set -x PATH $GOPATH/bin $PATH
end
set -x PATH $GOROOT/bin $PATH
set -x GO111MODULE on


