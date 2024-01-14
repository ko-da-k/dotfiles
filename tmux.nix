{ config, pkgs, ... }:

{
  home.file = {
    ".tmux.conf".source = ./.tmux.conf;
  };
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/tmux.nix
  programs.tmux = {
    enable = true;
  };
}
