# only config files outside of home-manager
{ config, pkgs, ... }:

{
  xdg.configFile."alacritty/dracula.toml".source = ./.config/alacritty/dracula.toml;
  xdg.configFile."alacritty/catppuccin.toml".source = ./.config/alacritty/catppuccin.toml;
  xdg.configFile."alacritty/everforest.toml".source = ./.config/alacritty/everforest.toml;
  xdg.configFile."alacritty/alacritty.toml".source = ./.config/alacritty/alacritty.toml;
  xdg.configFile."ghostty/config".source = ./.config/ghostty/config;
  xdg.configFile."git/ignore".source = ./.config/git/ignore;
  xdg.configFile."zed/settings.json".source = ./.config/zed/settings.json;
  xdg.configFile."zed/keymap.json".source = ./.config/zed/keymap.json;
}
