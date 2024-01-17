{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/zsh.nix
  programs.zsh = {
    enable = true;
  };
}
