{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/bash.nix
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "lsd -l";
      lla = "lsd -la";
      view = "vim -RM";
      ghqcd = "cd $(ghq list --full-path | fzf)";
      lg = "lazygit";
      k = "kubectl";
    };
    profileExtra = ''
      # xdg
      export XDG_CONFIG_HOME=$HOME/.config
      export XDG_CACHE_HOME=$HOME/.cache

      # brew
      eval $(/opt/homebrew/bin/brew shellenv)

      function share_history {
        history -a
        history -c
        history -r
      }
      PROMPT_COMMAND="share_history"
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
      eval "$(fzf --bash)"


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
  };
}
