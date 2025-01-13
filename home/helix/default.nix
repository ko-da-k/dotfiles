{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/helix.nix
  programs.helix = {
    enable = true;

    settings = {
      theme = "everforest_dark";
      editor = {
        lsp.display-messages = true;
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "error";
        };
        cursor-shape = {
          insert = "bar";
        };
      };
      keys = {
        insert = {
          "C-[" = "normal_mode";
        };
      };
    };
  };
}

