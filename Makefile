.PHONY: extra

# flake の username と一致する OS ユーザー名を自動取得する。
# 別ユーザーを対象にする場合は `make switch USERNAME=foo` で上書き可能。
USERNAME ?= $(shell whoami)

all: install-home-manager switch gc

# https://nix-community.github.io/home-manager/index.xhtml#ch-nix-flakes
install-home-manager:
	nix build --verbose .#homeConfigurations.$(USERNAME).activationPackage
	./result/activate
	home-manager --version

update-home-manager:
	nix flake update
	nix build --verbose .#homeConfigurations.$(USERNAME).activationPackage
	./result/activate
	home-manager --version

build:
	home-manager build -v --flake .#$(USERNAME)

switch:
	home-manager switch -v --flake .#$(USERNAME)

gc:
	nix-collect-garbage

