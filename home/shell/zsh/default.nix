{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/zsh.nix
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "lsd -l";
      lla = "lsd -la";
      view = "vim -RM";
      ghqcd = "cd $(ghq list --full-path | fzf)";
      lg = "lazygit";
      k = "kubectl";
    };
    syntaxHighlighting = {
      enable = true;
    };
    autosuggestion = {
      enable = true;
    };
    profileExtra = ''
      # xdg
      export XDG_CONFIG_HOME=$HOME/.config
      export XDG_CACHE_HOME=$HOME/.cache

      # brew
      eval $(/opt/homebrew/bin/brew shellenv)
    '';
    initExtra = ''
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix

      # fzf
      # https://draculatheme.com/fzf
      export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
      # Set up fzf key bindings and fuzzy completion
      source <(fzf --zsh)


      # gcloud
      export PATH=$HOME/.local/google-cloud-sdk/bin:$PATH

      # local
      export PATH=$HOME/.local/bin:$PATH

      # mise
      export PATH=$HOME/.local/share/mise/shims:$PATH

      # jetbrains
      export PATH=$HOME/Library/Application\ Support/JetBrains/Toolbox/script:$PATH

      # go
      export PATH=$HOME/go/bin:$PATH

      # cargo
      export PATH=$HOME/.cargo/bin:$PATH

      # krew
      export PATH=$HOME/.krew/bin:$PATH

      # gke
      export USE_GKE_GCLOUD_AUTH_PLUGIN=true
    '';
    plugins = [
      {
        # will source zsh-autosuggestions.plugin.zsh
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        # will source zsh-syntax-highlighting.zsh
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0";
          sha256 = "iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
        };
      }
    ];
  };
}
