#!/bin/bash

# zed の設定は zed 上からインタラクティブに編集することが多い
# nix で管理を行うと Read Only になるため、シンボリックリンクを貼ることで対応する

set -eu -o pipefail -x

cd $(dirname "$0")

ln -sf "$(pwd)/settings.json" "$HOME/.config/zed/settings.json"
ln -sf "$(pwd)/keymap.json" "$HOME/.config/zed/keymap.json"
