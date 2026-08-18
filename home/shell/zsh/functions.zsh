# zsh 関数。default.nix の initContent から source される。
#
# nix store 上のパスとして埋め込まれるので、このファイル内から
# 相対パスで別ファイルを参照しないこと。

# --- pr-review ---------------------------------------------------------------
#
# GitHub の Pull Request をレビューする環境を一発で立ち上げる。
#
#   1. PR の head/base を fetch し、専用の jj workspace を切る
#   2. herdr の workspace (space) をその jj workspace の cwd で作る
#   3. pane を左右に分割し、右で hunk の diff、左で claude を起動する
#
# 引数は PR の URL か、PR 番号。番号だけの場合は cwd のリポジトリを対象にする。
#
# Example:
#   pr-review https://github.com/ko-da-k/dotfiles/pull/123
#   pr-review 123          # 対象リポジトリ配下にいる場合
pr-review() {
  emulate -L zsh
  setopt local_options err_return pipe_fail

  local arg="$1"
  if [[ -z "$arg" ]]; then
    print -u2 "pr-review: usage: pr-review <PR-URL|PR-NUMBER>"
    return 2
  fi

  local dep
  for dep in gh jj git jq herdr hunk claude; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      print -u2 "pr-review: '$dep' が PATH にありません"
      return 1
    fi
  done

  # --- 引数の解決 ------------------------------------------------------------
  # URL 形式なら owner/repo/番号 をすべて URL から取る。
  # 番号だけなら cwd のリポジトリを gh に解決させる。
  local owner repo num
  local from_cwd=0
  if [[ "$arg" =~ '^https?://github\.com/([^/]+)/([^/]+)/pull/([0-9]+)' ]]; then
    owner="${match[1]}"
    repo="${match[2]}"
    num="${match[3]}"
  elif [[ "$arg" =~ '^[0-9]+$' ]]; then
    num="$arg"
    from_cwd=1
    local nwo
    if ! nwo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)"; then
      print -u2 "pr-review: cwd から GitHub リポジトリを解決できません。PR の URL を渡してください"
      return 1
    fi
    owner="${nwo%%/*}"
    repo="${nwo##*/}"
  else
    print -u2 "pr-review: '$arg' は PR の URL でも番号でもありません"
    return 2
  fi

  # jj workspace の追加と git fetch は「元のリポジトリ」に対して行う必要がある。
  # cwd を使わず ghq のパスを優先するのは、レビュー用 workspace の中から
  # さらに pr-review を叩いたときに、workspace 自身 (.git を持たない) を
  # 元リポジトリだと誤認しないため。
  local ghq_path="${GHQ_ROOT:-$HOME/ghq}/github.com/${owner}/${repo}"
  local src_repo="$ghq_path"
  if [[ ! -d "$src_repo" ]]; then
    # cwd から owner/repo を解決した場合に限り cwd のリポジトリへフォールバックする。
    # URL 指定でこれをやると、別のリポジトリにいるときに全く無関係な
    # リポジトリを対象にしてしまう。
    if (( from_cwd )); then
      src_repo="$(git rev-parse --show-toplevel 2>/dev/null)" || src_repo=""
    else
      src_repo=""
    fi
    if [[ -z "$src_repo" ]]; then
      print -u2 "pr-review: ${ghq_path} がありません。先に 'ghq get ${owner}/${repo}' してください"
      return 1
    fi
  fi

  # jj workspace を切るので colocated な jj リポジトリであることが前提。
  if [[ ! -d "${src_repo}/.jj" ]]; then
    print -u2 "pr-review: ${src_repo} は jj リポジトリではありません ('jj git init --colocate' が必要)"
    return 1
  fi

  local pr_url="https://github.com/${owner}/${repo}/pull/${num}"

  # --- PR のメタデータ取得 ---------------------------------------------------
  local meta
  if ! meta="$(gh pr view "$num" --repo "${owner}/${repo}" \
      --json baseRefName,title --jq '[.baseRefName, .title] | @tsv')"; then
    print -u2 "pr-review: ${owner}/${repo}#${num} を取得できません"
    return 1
  fi
  local base title
  base="${meta%%$'\t'*}"
  title="${meta#*$'\t'}"

  # --- PR の head / base を fetch -------------------------------------------
  # head は refs/pull/<N>/head から取る。ブランチ名経由ではなくこの ref を使うのは、
  # fork からの PR でも head が origin 側に存在するため。
  # colocated リポジトリなので git で fetch してから jj に import する。
  print -r -- "==> fetching ${owner}/${repo}#${num} (base: ${base})"
  git -C "$src_repo" fetch --quiet origin \
    "+refs/pull/${num}/head:refs/heads/pr-${num}" \
    "+refs/heads/${base}:refs/remotes/origin/${base}"
  jj -R "$src_repo" git import

  # レビュー対象の revset。'..' は base に含まれない PR のコミット群を指し、
  # jj diff -r '<base>..<head>' は jj diff --from <merge-base> --to <head> と等価になる。
  # ('::' だと base 自身の変更まで含んでしまうので使わない)
  local revset="${base}@origin..pr-${num}"

  # --- jj workspace ----------------------------------------------------------
  local ws_dir="${XDG_CACHE_HOME:-$HOME/.cache}/pr-review/${owner}/${repo}/${num}"
  if [[ -d "$ws_dir" ]]; then
    # 既にレビュー環境がある場合は作り直さず、working copy だけ新しい head に載せ替える。
    print -r -- "==> reusing jj workspace: ${ws_dir}"
    jj -R "$ws_dir" new "pr-${num}"
  else
    print -r -- "==> creating jj workspace: ${ws_dir}"
    mkdir -p "${ws_dir:h}"
    jj -R "$src_repo" workspace add --name "pr-${num}" -r "pr-${num}" "$ws_dir"
  fi

  # --- herdr の space と pane ------------------------------------------------
  # --focus はここではなく最後に行う。先にフォーカスを移すと、この関数の残りの
  # 出力 (最後のサマリ) が見えなくなった元の pane に流れてしまうため。
  local created split hw hp_left hp_right
  created="$(herdr workspace create --cwd "$ws_dir" --label "${repo}#${num}" --no-focus)" || created=""
  # workspace.create のレスポンスは workspace と root_pane の両方を返すので、
  # pane list を引かなくても作りたての pane の id が分かる。
  hw="$(__pr_review_json '.result.workspace.workspace_id' "$created")"
  hp_left="$(__pr_review_json '.result.root_pane.pane_id' "$created")"
  if [[ -z "$hw" || -z "$hp_left" ]]; then
    print -u2 "pr-review: herdr workspace を作成できませんでした"
    return 1
  fi

  # 左 (元の pane) を AI、右 (分割で生まれる pane) を hunk にする。
  # --no-focus なので分割後もフォーカスは左に残る。
  split="$(herdr pane split "$hp_left" --direction right --cwd "$ws_dir" --no-focus)" || split=""
  hp_right="$(__pr_review_json '.result.pane.pane_id' "$split")"
  if [[ -z "$hp_right" ]]; then
    print -u2 "pr-review: pane を分割できませんでした"
    return 1
  fi

  herdr pane rename "$hp_left" "review" >/dev/null
  herdr pane rename "$hp_right" "diff" >/dev/null

  __pr_review_wait_prompt "$hp_right"
  herdr pane run "$hp_right" "hunk diff ${(q)revset} --watch"

  # review-pr スキルの「diff の取得方法をユーザーに確認」ステップを省けるよう、
  # revset と PR の情報をプロンプトに埋めておく。改行を含めると途中で送信されるので一行にする。
  local prompt="/review-pr ${pr_url} (${title}) のレビューをお願いします。レビュー対象の diff は cwd で \`jj diff -r ${(q)revset}\` で取得できます。"
  __pr_review_wait_prompt "$hp_left"
  herdr pane run "$hp_left" "claude ${(q)prompt}"

  # サマリは呼び出し元の pane に出るので、フォーカスを移す前に出し切っておく。
  print -r -- "==> ${owner}/${repo}#${num} ${title}"
  print -r -- "    workspace: ${ws_dir}"
  print -r -- "    revset:    ${revset}"

  herdr workspace focus "$hw" >/dev/null 2>&1 || true
}

# pane に生えたシェルのプロンプトが出るまで待つ。
#
# pane を作った直後は zsh の初期化 (compinit / fzf / zoxide) が走っており、
# そこへ herdr pane run でコマンドを送ると入力が取りこぼされうる。
# starship の success_symbol が '>' なので、それが見えたらプロンプトが出たとみなす。
# 待てなかった場合でもコマンド自体は送るので、失敗は無視する。
__pr_review_wait_prompt() {
  emulate -L zsh
  herdr wait output "$1" --match '>' --source visible --timeout 10000 >/dev/null 2>&1 || true
}

# herdr の CLI が stdout に出す JSON から値を 1 つ取り出す。
#
#   __pr_review_json <jq-filter> <json>
#
# herdr のレスポンスは {"id": "<リクエスト id>", "result": {...}} という形で、
# トップレベルの "id" は workspace/pane の id ではないので必ず result 以下を見る。
#
# 見つからない場合は何も出力せず 0 で返し、判定は呼び出し側の空文字チェックに任せる
# (err_return 下で非ゼロを返すと呼び出し側のエラーメッセージに到達しないため)。
__pr_review_json() {
  emulate -L zsh
  print -r -- "$2" | jq -r "$1 // empty" 2>/dev/null
  return 0
}
