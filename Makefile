all: build

# https://nix-community.github.io/home-manager/index.xhtml#ch-nix-flakes
install-home-manager:
	nix build --verbose .#homeConfigurations.ko-da-k.activationPackage
	./result/activate
	home-manager --version

update-home-manager:
	nix flake update
	nix build --verbose .#homeConfigurations.ko-da-k.activationPackage
	./result/activate
	home-manager --version

build:
	home-manager build -v --flake .#ko-da-k

switch:
	home-manager switch -v --flake .#ko-da-k

gc:
	nix-collect-garbage
