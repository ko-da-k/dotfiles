ln -sf ~/dotfiles/.vim/dein/dein.toml ~/.vim/dein/dein.toml
ln -sf ~/dotfiles/.vim/dein/dein_lazy.toml ~/.vim/dein/dein_lazy.toml

if [ ! -e ~/.vim/ftplugin ]; then
    mkdir ~/.vim/ftplugin
fi
ln -sf ~/dotfiles/.vim/ftplugin/python.vim ~/.vim/ftplugin/python.vim

