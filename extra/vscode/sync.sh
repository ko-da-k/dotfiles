#!/bin/bash

# vscode の設定は vscode 上からインタラクティブに編集することが多い
# nix で管理を行うと Read Only になるため、シンボリックリンクを貼ることで対応する

set -eu -o pipefail -x

cd $(dirname "$0")

vscode_config_dir="$HOME/Library/Application Support/Code/User"

ln -sf "$(pwd)/settings.json" "$vscode_config_dir/settings.json"
ln -sf "$(pwd)/keybindings.json" "$vscode_config_dir/keybindings.json"
