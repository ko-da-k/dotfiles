# only config files outside of home-manager
# mkOutOfStoreSymlink: XDG配下 → dotfiles配下 へのシンボリックリンクを作成
# これにより GUI アプリから直接編集可能になる
{ config, pkgs, dotfilesPath, ... }:

let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
  extraPath = "${dotfilesPath}/extra";
in
{
  # alacritty
  xdg.configFile."alacritty/dracula.toml".source = mkSymlink "${extraPath}/.config/alacritty/dracula.toml";
  xdg.configFile."alacritty/catppuccin.toml".source = mkSymlink "${extraPath}/.config/alacritty/catppuccin.toml";
  xdg.configFile."alacritty/everforest.toml".source = mkSymlink "${extraPath}/.config/alacritty/everforest.toml";
  xdg.configFile."alacritty/alacritty.toml".source = mkSymlink "${extraPath}/.config/alacritty/alacritty.toml";

  # ghostty
  xdg.configFile."ghostty/config".source = mkSymlink "${extraPath}/.config/ghostty/config";

  # git
  xdg.configFile."git/ignore".source = mkSymlink "${extraPath}/.config/git/ignore";

  # zed
  xdg.configFile."zed/settings.json".source = mkSymlink "${extraPath}/.config/zed/settings.json";
  xdg.configFile."zed/keymap.json".source = mkSymlink "${extraPath}/.config/zed/keymap.json";

  # jj
  xdg.configFile."jj/config.toml".source = mkSymlink "${extraPath}/.config/jj/config.toml";

  # vscode
  home.file."Library/Application Support/Code/User/settings.json".source = mkSymlink "${extraPath}/vscode/settings.json";
  home.file."Library/Application Support/Code/User/keybindings.json".source = mkSymlink "${extraPath}/vscode/keybindings.json";
}
