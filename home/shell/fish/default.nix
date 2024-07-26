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
      # https://draculatheme.com/fzf
      set -Ux FZF_DEFAULT_OPTS "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

      # gcloud
      set -x PATH $HOME/.local/google-cloud-sdk/bin $PATH

      # local
      set -x PATH $HOME/.local/bin $PATH

      # mise
      set -x PATH $HOME/.local/share/mise/shims $PATH

      # jetbrains
      set -x PATH $PATH "$HOME/Library/Application Support/Jetbrains/Toolbox/scripts"

      # go
      set -x PATH $HOME/go/bin $PATH

      # cargo
      set -x PATH $PATH $HOME/.cargo/bin

      # krew
      set -x PATH $PATH $HOME/.krew/bin

      # gke
      set -x USE_GKE_GCLOUD_AUTH_PLUGIN True
    '';
  };
}
