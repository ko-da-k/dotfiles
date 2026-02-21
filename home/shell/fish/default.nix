{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/fish.nix
  programs.fish = {
    enable = true;
    shellAliases = {
      view = "vim -RM";
      ghqcd = "cd (ghq list --full-path | fzf)";
    };
    shellAbbrs = {
      k = "kubectl";
      lg = "lazygit";
      lla = "lsd -la";
      gco = "git checkout";
    };
    plugins = [
      {
        name = "dracula";
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "fish";
          rev = "269cd7d76d5104fdc2721db7b8848f6224bdf554";
          sha256 = "Hyq4EfSmWmxwCYhp3O8agr7VWFAflcUe8BUKh50fNfY=";
        };
      }
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "v10.2";
          sha256 = "1/MLKkUHe4c9YLDrH+cnL+pLiSOSERbIZSM4FTG3wF0=";
        };
      }
    ];
    shellInit = '''';
    loginShellInit = ''
      # xdg
      set -x XDG_CONFIG_HOME $HOME/.config
      set -x XDG_CACHE_HOME $HOME/.cache

      # brew
      eval $(/opt/homebrew/bin/brew shellenv)
    '';
    interactiveShellInit = ''
      # Nix
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      end
      # End Nix

      # fzf
      set -Ux FZF_DEFAULT_OPTS "\
      --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
      --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
      --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
      --color=selected-bg:#494d64 \
      --multi"

      # 下のほうが優先
      export PATH=$HOME/Library/Application\ Support/JetBrains/Toolbox/script:$PATH
      export PATH=$HOME/.local/google-cloud-sdk/bin:$PATH
      export PATH=$HOME/.local/share/mise/shims:$PATH
      export PATH=$HOME/.krew/bin:$PATH
      export PATH=$HOME/go/bin:$PATH
      export PATH=$HOME/.cargo/bin:$PATH
      export PATH=$HOME/.local/bin:$PATH

      export USE_GKE_GCLOUD_AUTH_PLUGIN=true
    '';
  };
}
