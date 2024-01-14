{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/starship.nix
  # https://starship.rs/ja-jp/installing/
  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      format = ''
      $gcloud$aws$kubernetes$golang$python$rust$nodejs$dotnet
      $directory$git_branch$git_commit$git_status
      $nix_shell$character'';

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
      
      golang = {
        disabled=false;
        symbol = ''go'';
        format = ''[$symbol(($version))](bold cyan)'';
      };

      python = {
        disabled=false;
        symbol = ''py'';
        format = ''[$symbol($version)($virtualenv)]($style)'';
        python_binary = [''./venv/bin/python'' ''python'' ''python3''];
      };
      
      rust = {
        disabled=false;
        symbol=''rs'';
        format = ''[$symbol(($version))]($style)'';
      };
      
      nodejs = {
        disabled=false;
        symbol=''nodejs'';
        format = ''[$symbol(($version)|($engines_version))]($style)'';
      };
      
      dotnet = {
        disabled=false;
        symbol=''.NET'';
        format = ''[$symbol(($version)|($tfm))]($style)'';
      };
      
      nix_shell = {
        disabled=false;
        symbol=''nix'';
        format = ''[$symbol(($state):($name))]($style)'';
      };
    };
  };
}
