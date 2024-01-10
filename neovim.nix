{ config, pkgs, ... }:

{

  home.file = {
    ".ideavimrc".source = ./.ideavimrc;
    ".vimrc.keymap".source = ./.vimrc.keymap;
  };

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/neovim.nix
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
