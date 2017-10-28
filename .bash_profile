source ~/.bashrc

if [[ -f ~/.pyenv ]]; then 
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

if [[ -f ~/.nodebrew/nodebrew ]]; then
  export PATH="$HOME/.nodebrew/current/bin:$PATH"
fi

# export PGDATA="/usr/local/var/postgres"

# export GOPATH="$HOME/.go"
# export PATH="$GOPATH/bin:$PATH"

# export PATH="/usr/local/opt/openssl/bin:$PATH"
