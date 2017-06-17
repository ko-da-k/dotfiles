ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.vim/dein/dein.toml ~/.vim/dein/dein.toml
ln -sf ~/dotfiles/.vim/dein/dein_lazy.toml ~/.vim/dein/dein_lazy.toml

if [ ! -e ~/.vim/after ]; then
    mkdir ~/.vim/after
    mkdir ~/.vim/after/ftplugin
fi

for file in `find .vim/after/ftplugin -maxdepth 1 -type f`; do
    ln -sf ~/dotfiles/$file ~/$file
done