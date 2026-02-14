---
name: review-pr
description: pull request の内容を確認しレビューする
user-invocable: true
allowed-tools: Bash(jj log *), Bash(jj st *), Bash(jj diff *), Bash(jj show *), Bash(jj check *), Bash(gh *)
---

# review-pr スキル

pull request の内容を確認しレビューします。

## 実行フロー

1. レビュー対象の diff を取得する方法をユーザーに確認
  a. 例: `jj diff --from main --to feature-branch` など
2. PR Description (=diff の目的)をユーザーに確認
  a. 例: `gh pr view {pr_number}` 等。直接入力でも可
3. 変更内容を分析
  a. 変更されたファイルとその内容を確認
  b. 変更の種類を特定（feat, fix, refactor など）
4. レビューコメントを生成
  a. PR Description の内容との一致、コードの品質、可読性、パフォーマンス、セキュリティなどの観点からコメントを生成
  b. 変更内容に対する具体的なフィードバックを提供
5. ユーザーに確認
  a. 生成したレビューコメントを提示

## 注意事項

- サンドボックス制限がある場合は `dangerouslyDisableSandbox: true` を使用
- jj st, jj show, jj log は並列で実行可能
