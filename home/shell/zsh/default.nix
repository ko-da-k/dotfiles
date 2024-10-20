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
      export FZF_DEFAULT_OPTS=" \
        --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
        --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
        --color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
        --color=selected-bg:#51576d \
        --multi"
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
