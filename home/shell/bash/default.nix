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
      # https://draculatheme.com/fzf
      export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
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
