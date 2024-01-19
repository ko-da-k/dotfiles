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
    };

    extraConfig = ''
      $env.config = {
        keybindings: [
          {
            name: fuzzy_history
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: [
              {
                send: ExecuteHostCommand
                cmd: "commandline (
                  history 
                    | each { |it| $it.command } 
                    | uniq 
                    | reverse 
                    | str join (char -i 0) 
                    | fzf --read0 --layout=reverse --height=40% -q (commandline) 
                    | decode utf-8 
                    | str trim
                )"
              }
            ]
          }
        ]
      }
    '';
  };
}
