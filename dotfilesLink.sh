ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.bash_profile ~/.bash_profile
ln -sf ~/dotfiles/.vim/dein/dein.toml ~/.vim/dein/dein.toml
ln -sf ~/dotfiles/.vim/dein/dein_lazy.toml ~/.vim/dein/dein_lazy.toml
if [ ! -e ~/.vim/ftplugin ]; then
    mkdir ~/.vim/ftplugin
fi
ln -sf ~/dotfiles/.vim/ftplugin/python.vim ~/.vim/ftplugin/python.vim
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.ideavimrc ~/.ideavimrc
