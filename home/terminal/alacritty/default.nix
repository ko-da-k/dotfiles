{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/alacritty.nix
  programs.alacritty= {
    enable = true;
  };
  xdg.configFile."alacritty/dracula.toml".source = ./dracula.toml;
  xdg.configFile."alacritty/alacritty.toml".source = ./alacritty.toml;
}
