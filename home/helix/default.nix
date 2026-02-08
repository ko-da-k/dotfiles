{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/helix.nix
  programs.helix = {
    enable = true;

    settings = {
      theme = "everforest_dark";
      editor = {
        mouse = true;
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
          normal = "block";
          select = "underline";
        };
      };
      keys = {
        insert = {
          "C-[" = "normal_mode";
        };
        normal = {
          C-y = [
            ":sh rm -f /tmp/unique-file"
            ":insert-output yazi %{buffer_name} --chooser-file=/tmp/unique-file"
            ":insert-output echo \"\\x1b[?1049h\\x1b[?2004h\" > /dev/tty"
            ":open %sh{cat /tmp/unique-file}"
            ":redraw"
          ];
          C-t = ":sh lsd --tree --depth=3";
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
        vscode-json-languageserver = {
          command = "vscode-json-languageserver";
          args = [ "--stdio" ];
        };
      };
      language = [
        {
          name = "rust";
          auto-format = false;
        }
        {
          name = "json";
          language-servers = [ "vscode-json-languageserver" ];
          formatter = {
            command = "deno";
            args = [
              "fmt"
              "-"
              "--ext"
              "json"
            ];
          };
        }
        {
          name = "jsonc";
          language-servers = [ "vscode-json-languageserver" ];
          formatter = {
            command = "deno";
            args = [
              "fmt"
              "-"
              "--ext"
              "jsonc"
            ];
          };
        }
        {
          name = "bash";
          file-types = [
            "sh"
            "bash"
          ];
          indent = {
            tab-width = 2;
            unit = " ";
          };
          language-servers = [ "bash-language-server" ];
        }
      ];
    };
  };
}
