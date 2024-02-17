# only config files outside of home-manager
{ config, pkgs, ... }:

{
  home.file = {
    ".bashrc".source = ./.bashrc;
    ".hyper.js".source = ./.hyper.js;
    ".zshrc".source = ./.zshrc;
  };
  xdg.configFile."alacritty/dracula.toml".source = ./.config/alacritty/dracula.toml;
  xdg.configFile."alacritty/alacritty.toml".source = ./.config/alacritty/alacritty.toml;
  xdg.configFile."git/ignore".source = ./.config/git/ignore;
}

