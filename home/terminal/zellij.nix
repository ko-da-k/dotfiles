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
          // Floating panes
          bind "Alt f" { ToggleFloatingPanes; }
          
          // New tab
          bind "Alt t" { NewTab; }
          
          // New pane
          bind "Alt n" { NewPane; }
          bind "Alt N" { NewPane "Down"; }
          
          // Close pane
          bind "Alt w" { CloseFocus; }
          
          // Move focus between panes
          bind "Alt Left" { MoveFocus "Left"; }
          bind "Alt Right" { MoveFocus "Right"; }
          bind "Alt Up" { MoveFocus "Up"; }
          bind "Alt Down" { MoveFocus "Down"; }
          
          // Go to tab by number
          bind "Alt 1" { GoToTab 1; }
          bind "Alt 2" { GoToTab 2; }
          bind "Alt 3" { GoToTab 3; }
          bind "Alt 4" { GoToTab 4; }
          bind "Alt 5" { GoToTab 5; }
          bind "Alt 6" { GoToTab 6; }
          bind "Alt 7" { GoToTab 7; }
          bind "Alt 8" { GoToTab 8; }
          bind "Alt 9" { GoToTab 9; }
        }
      }
    '';
  };
}
