{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/nushell.nix
  programs.nushell = {
    enable = true;

    shellAliases = {
      k = "kubectl";
      lg = "lazygit";
      la = "ls -a";
      lla = "ls -la";
      gco = "git checkout";
      ghqcd = "cd (ghq list --full-path | fzf)";
    };

    extraConfig = builtins.readFile ./config.nu;
  };
}
