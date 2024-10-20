{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/zellij.nix
  programs.zellij = {
    enable = true;

    settings =  {
      theme = "catppuccin-frappe";
      default_mode = "locked";
    };
  };
}
