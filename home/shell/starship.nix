{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/starship.nix
  # https://starship.rs/ja-jp/installing/
  programs.starship = {
    enable = true;

    settings = {
      add_newline = true;

      format = ''
        $gcloud$aws$kubernetes$nix_shell$direnv
        $directory$git_branch$git_commit$git_status''${custom.jj_bookmark}
        $shell$character'';

      package.disabled = true;

      character = {
        success_symbol = ''[>](bold green)'';
        error_symbol = ''[✗](bold red)'';
        vicmd_symbol = ''[V](bold green)'';
      };

      kubernetes = {
        disabled = false;
        format = ''[$symbol($context:$namespace)](green) '';
      };

      gcloud = {
        disabled = false;
        format = ''[$symbol($project:$region)](cyan) '';
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
        symbol = ''❄️ '';
        format = ''[$symbol$state\($name\)]($style) '';
      };

      directory = {
        truncate_to_repo = false;
        truncation_length = 2;
      };

      git_branch = {
        format = ''[$symbol$branch]($style) '';
      };

      custom.jj_bookmark = {
        description = "current change に最も近い jj bookmark を表示";
        command = ''jj log -r 'heads(::@ & bookmarks())' --no-graph -T 'bookmarks.join(",")' --limit 1'';
        when = ''jj root'';
        format = ''[🔖 $output]($style) '';
        style = ''purple bold'';
      };

      direnv = {
        disabled = false;
      };

      shell = {
        disabled = false;
      };
    };
  };
}
