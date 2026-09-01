#!/usr/bin/env bash

set -euo pipefail

readonly dotfiles_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly config_file="${dotfiles_root}/chezmoi/base/.config/jj/config.toml"
readonly test_repo="${JJ_TEST_REPO:-/Users/ko-da-k/ghq/github.com/ko-da-k/playground-jj}"
readonly commit_id_template='commit_id ++ "\n"'

test_lb_shows_current_branch_history() {
  # Given: 現在の作業コピーの祖先ではない trunk が存在する jj repository
  local alternate_trunk
  alternate_trunk="$(jj --ignore-working-copy --repository "${test_repo}" \
    log --revisions 'heads(bookmarks() ~ ::@)' --limit 1 \
    --no-graph --template "${commit_id_template}")"
  [[ -n "${alternate_trunk}" ]]

  local trunk_config="revset-aliases.\"trunk()\"=\"${alternate_trunk}\""
  local expected
  expected="$(jj --ignore-working-copy --repository "${test_repo}" \
    --config "${trunk_config}" \
    log --revisions '::@ | ::trunk()' --no-graph --template "${commit_id_template}")"

  # When: jj lb で現在の branch と trunk のログを取得する
  local actual
  actual="$(jj --ignore-working-copy --repository "${test_repo}" \
    --config-file "${config_file}" \
    --config "${trunk_config}" \
    lb --no-graph --template "${commit_id_template}")"

  # Then: 現在の作業コピーと trunk の祖先がどちらも表示される
  [[ "${actual}" == "${expected}" ]]
}

test_lt_shows_trunk_history() {
  # Given: trunk 未統合の head が存在する jj repository
  local expected
  expected="$(jj --ignore-working-copy --repository "${test_repo}" \
    log --revisions '::trunk()' --no-graph --template "${commit_id_template}")"

  # When: jj lt で trunk のログを取得する
  local actual
  actual="$(jj --ignore-working-copy --repository "${test_repo}" \
    --config-file "${config_file}" \
    lt --no-graph --template "${commit_id_template}")"

  # Then: trunk とその祖先だけが表示される
  [[ "${actual}" == "${expected}" ]]
}

test_la_shows_all_history() {
  # Given: 複数の head が存在する jj repository
  local expected
  expected="$(jj --ignore-working-copy --repository "${test_repo}" \
    log --revisions 'all()' --no-graph --template "${commit_id_template}")"

  # When: jj la ですべてのログを取得する
  local actual
  actual="$(jj --ignore-working-copy --repository "${test_repo}" \
    --config-file "${config_file}" \
    la --no-graph --template "${commit_id_template}")"

  # Then: すべての visible commit が表示される
  [[ "${actual}" == "${expected}" ]]
}

test_config_is_valid() {
  # Given: 変更後の jj config file
  local config="${config_file}"

  # When: jj に設定全体を読み込ませる
  local result
  result="$(jj --ignore-working-copy --repository "${test_repo}" \
    --config-file "${config}" config list aliases)"

  # Then: alias 設定を parse できる
  [[ -n "${result}" ]]
}

test_lb_shows_current_branch_history
test_lt_shows_trunk_history
test_la_shows_all_history
test_config_is_valid
