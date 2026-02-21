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
      --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
      --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
      --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
      --color=selected-bg:#494d64 \
      --multi"

      # Set up fzf key bindings and fuzzy completion
      eval "$(fzf --bash)"

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
