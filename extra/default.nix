# only config files outside of home-manager
{ config, pkgs, ... }:

{
  home.file = {
    ".hyper.js".source = ./.hyper.js;
  };
  xdg.configFile."alacritty/dracula.toml".source = ./.config/alacritty/dracula.toml;
  xdg.configFile."alacritty/alacritty.toml".source = ./.config/alacritty/alacritty.toml;
  xdg.configFile."git/ignore".source = ./.config/git/ignore;
  xdg.configFile."zed/settings.json".source = ./.config/zed/settings.json;
}
