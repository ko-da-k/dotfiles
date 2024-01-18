{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/starship.nix
  # https://starship.rs/ja-jp/installing/
  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      format = ''
      $gcloud$aws$kubernetes$directory$git_branch$git_commit$git_status
      $nix_shell$shell$character'';

      package.disabled = true;

      character = {
        success_symbol = ''[>>>](bold green)'';
        error_symbol = ''[✗✗✗](bold red)'';
        vicmd_symbol = ''[V](bold green)'';
      };

      kubernetes = {
        disabled = false;
        format = ''[$symbol($context($namespace))](green)'';
      };

      gcloud = {
        disabled = false;
        symbol = ''gcloud'';
        format = ''[$symbol($account(@domain)(($project))$region)](cyan)'';
      };
      gcloud.region_aliases = {
        us-central1 = ''uc1'';
        asia-northeast1 = ''an1'';
      };
      
      aws = {
        disabled = false;
        symbol = ''aws'';
        format = ''[$symbol(($profile$region))]($style)'';
      };
      
      nix_shell = {
        disabled = false;
        symbol = ''nix'';
        format = ''[$symbol(($state):($name))]($style)'';
      };

      shell = {
        disabled = false;
      };
    };
  };
}
