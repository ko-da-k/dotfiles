source ~/.bashrc

if [ -d ~/.pyenv ]; then 
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

if [ -d ~/.rbenv ]; then
  export RBENV_ROOT="$HOME/.rbenv"
  export PATH="$RBENV_ROOT/bin:$PATH"
  eval "$(rbenv init -)"
fi

if [ -d ~/.nodebrew/nodebrew ]; then
  export PATH="$HOME/.nodebrew/current/bin:$PATH"
fi

if [ -d ~/.go ]; then
  export GOROOT="$HOME/.go"
  export GOPATH="$HOME/Documents/code/go"
  export PATH="$GOPATH/bin:$PATH"
fi
# export PGDATA="/usr/local/var/postgres"

# export GOPATH="$HOME/.go"
# export PATH="$GOPATH/bin:$PATH"

# export PATH="/usr/local/opt/openssl/bin:$PATH"
