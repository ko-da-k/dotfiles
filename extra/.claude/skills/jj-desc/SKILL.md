---
name: jj-desc
description: jujutsu のコミット説明をファイルごとの変更内容とともに自動生成
user-invocable: true
allowed-tools: Bash(jj log *), Bash(jj st *), Bash(jj diff *), Bash(jj desc *), Bash(jj show *), Bash(jj check *)
---

# jj-desc スキル

jujutsu のコミット説明を自動生成します。

## 実行フロー

1. 現在の変更状態を確認
   - `jj st` で変更されたファイルを確認
   - `jj show` で現在のコミット内容と説明を確認
   - `jj log -n 5` で過去のコミット説明の形式を確認

2. 変更内容を分析
   - 各ファイルの差分を確認
   - 変更の種類を特定（feat, fix, refactor など）

3. コミット説明を生成
   - Conventional Commits 形式で記述
   - ファイルごとの変更内容を箇条書きで記述
   - 過去のコミット説明の形式を参考にする

4. ユーザーに確認
   - 生成した説明文を提示
   - 承認を得る

5. コミット説明を更新
   - `jj desc -m "..."` で説明を更新

## 注意事項

- サンドボックス制限がある場合は `dangerouslyDisableSandbox: true` を使用
- jj st, jj show, jj log は並列で実行可能
- ユーザーの承認を得てから jj desc を実行すること
