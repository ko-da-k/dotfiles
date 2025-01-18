{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/helix.nix
  programs.helix = {
    enable = true;

    settings = {
      theme = "everforest_dark";
      editor = {
        file-picker = {
          hidden = false;
        };
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "hint";
        };
        lsp = {
          enable = true;
          display-messages = true;
          display-progress-messages = true;
          display-inlay-hints = true;
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

    languages = {
      language-server = {
        rust-analyzer = {
          config = {
            checkOnSave.command = "clippy";
            command = "clippy";
          };
        };
      };
      language = [
        {
          name = "rust";
          auto-format = false;
        }
        {
          name = "json";
          formatter = { command = "prettier"; args = [ "--parser" "json"]; };
        }
        {
          name = "bash";
          file-types = ["sh" "bash"];
          indent = { tab-width = 2; unit = " "; };
          language-servers = ["bash-language-server"]; 
        }
      ];
    };
  };
}

