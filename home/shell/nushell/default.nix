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
      zg = "cd (ghq list --full-path | fzf)";
    };

    extraConfig = builtins.readFile ./config.nu;
  };

  # 用途ごとのユーティリティモジュール。
  # config.nu からは `use ./scripts/<name>.nu` で相対参照する。
  # ~/.config/nushell/scripts は nushell のデフォルト $env.NU_LIB_DIRS にも
  # 含まれるため、`use k8s.nu` のようなアドホックな読み込みもできる。
  xdg.configFile."nushell/scripts".source = ./scripts;
}
