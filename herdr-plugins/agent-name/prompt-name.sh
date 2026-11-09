#!/bin/sh
# 名前を入力させ、対象 pane の agent を rename する。
set -u

herdr="${HERDR_BIN_PATH:-herdr}"
# popup には HERDR_PANE_ID が渡らないので、open-prompt.sh が --env で渡す
pane_id="${AGENT_NAME_TARGET_PANE:-}"
[ -n "$pane_id" ] || exit 1

printf 'agent name: '
read -r name || exit 0
# 空白だけの名前を渡すと herdr は名前を消去するので、空入力として扱う
case "$name" in
  *[![:space:]]*) ;;
  *) exit 0 ;;
esac
if ! "$herdr" agent rename "$pane_id" "$name" >/dev/null; then
  # popup は終了と同時に閉じるので、エラーを読めるよう待つ
  printf 'press enter to close'
  read -r _
fi
