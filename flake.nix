{
  description = "Home Manager configuration of ko-da-k";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      # マシン固有の設定はここを編集する（single source of truth）
      username = "ko-da-k"; # OS のユーザー名（マシンによって変わる）
      homeDirectory = "/Users/${username}"; # macOS のホームディレクトリ
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [ ./home.nix ];

        extraSpecialArgs = {
          inherit username homeDirectory;
          dotfilesPath = "${homeDirectory}/ghq/github.com/ko-da-k/dotfiles";
        };
      };
    };
}
