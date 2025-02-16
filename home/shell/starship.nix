{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/starship.nix
  # https://starship.rs/ja-jp/installing/
  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      format = ''
      $cmd_duration
      $gcloud$aws$kubernetes
      $nix_shell$shell$python$elixir$golang$haskell
      $directory$git_branch$git_commit$git_status
      $character'';

      package.disabled = true;

      character = {
        success_symbol = ''[>>>](bold green)'';
        error_symbol = ''[✗✗✗](bold red)'';
        vicmd_symbol = ''[V](bold green)'';
      };

      cmd_duration = {
        disabled = false;
        min_time = 2000;
      };

      kubernetes = {
        disabled = false;
        format = ''[$symbol($context:$namespace)](green) '';
      };

      gcloud = {
        disabled = false;
        format = ''[$symbol($account:@$domain:$project:$region)](cyan) '';
      };
      gcloud.region_aliases = {
        us-central1 = ''uc1'';
        asia-northeast1 = ''an1'';
      };
      
      aws = {
        disabled = false;
        format = ''[$symbol($profile:$region)]($style) '';
      };
      
      nix_shell = {
        disabled = false;
        format = ''[$symbol($state:$name)]($style) '';
      };

      shell = {
        disabled = false;
      };

      python = {
        disabled = false;
        format = ''[$symbol($venv:$version)]($style) '';
      };

      elixir = {
        disabled = false;
        format = ''[$symbol($version \(OTP$otp_version))]($style) '';
      };

      golang = {
        disabled = false;
        format = ''[$symbol($version)]($style) '';
      };

      haskell = {
        disabled = false;
        format = ''[$symbol($version)]($style) '';
      };

      rust = {
        disabled = false;
      };
    };
  };
}
