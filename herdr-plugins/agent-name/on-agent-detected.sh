#!/bin/sh
# pane.agent_detected の event hook。名前が未設定の agent なら名前入力の popup を開く。
set -u

herdr="${HERDR_BIN_PATH:-herdr}"
pane_id="${HERDR_PANE_ID:-}"
[ -n "$pane_id" ] || exit 0

# released は agent の終了通知
released="$(printf '%s' "${HERDR_PLUGIN_EVENT_JSON:-}" | jq -r '.data.released // false' 2>/dev/null)"
[ "$released" != "true" ] || exit 0

# セッション復元などで再検知された、名前付きの agent には聞き直さない
name="$("$herdr" agent get "$pane_id" 2>/dev/null | jq -r '.result.agent.name // empty')"
[ -z "$name" ] || exit 0

exec sh "$(dirname "$0")/open-prompt.sh"
