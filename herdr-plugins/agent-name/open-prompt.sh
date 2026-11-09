#!/bin/sh
# HERDR_PANE_ID の agent に名前を付ける popup を開く。rename action と on-agent-detected.sh から呼ぶ。
set -u

herdr="${HERDR_BIN_PATH:-herdr}"
pane_id="${HERDR_PANE_ID:-}"
[ -n "$pane_id" ] || exit 0

# 他のモーダル表示中（ui_busy）などで開けなければ、名前を付けずに諦める
"$herdr" plugin pane open --plugin "$HERDR_PLUGIN_ID" --entrypoint prompt --placement popup \
  --env "AGENT_NAME_TARGET_PANE=$pane_id" >/dev/null 2>&1 || true
