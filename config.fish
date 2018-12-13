alias g git

if test -d ~/.pyenv
  set -x PYENV_ROOT $HOME/.pyenv
  set -x PATH $PYENV_ROOT/bin $PATH
  eval (pyenv init - | source)
end

if test -d ~/.nodebrew
  set -x PATH $HOME/.nodebrew/current/bin $PATH
end

if test -d ~/.go
  set -x GOROOT $HOME/.go
  set -x GOPATH $HOME/Document/code/go
  set -x PATH $GOROOT/bin $PATH
end

if test -d ~/.linuxbrew
  eval ($HOME/.linuxbrew/bin/brew shellenv | source)
  eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv | source)
  set -x PATH $HOME/.linuxbrew/bin $PATH
end