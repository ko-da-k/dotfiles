{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/zellij.nix
  programs.zellij = {
    enable = true;

    settings =  {
      theme = "catppuccin-frappe";
      default_mode = "locked";
      show_startup_tips = false;
    };

    layouts = {
      default = ''
      layout {
        default_tab_template {
          pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
          }
          children
          pane size=2 borderless=true {
            plugin location="zellij:status-bar"
          }
        }
        swap_floating_layout {
          floating_panes max_panes=1 {
            pane x="5%" y="5%" width="90%" height="90%"
          }
        }
      }
      '';
    };

    extraConfig = ''
      keybinds {
        locked {
          bind "Alt f" { ToggleFloatingPanes; }
        }
      }
    '';
  };
}
