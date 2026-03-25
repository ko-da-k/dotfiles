---
name: jj-desc
description: jujutsu のコミット説明をファイルごとの変更内容とともに自動生成
user-invocable: true
allowed-tools: Bash(jj log *), Bash(jj st *), Bash(jj diff *), Bash(jj desc *), Bash(jj show *) 
---

<!--
  Contextual Commits format:
  Based on https://github.com/berserkdisruptors/contextual-commits
  Copyright (c) 2026 Berserk Disruptors. MIT License.
-->

# jj-desc スキル

jujutsu のコミット説明を自動生成します。
Conventional Commits の subject line に加え、[contextual-commits](https://github.com/berserkdisruptors/contextual-commits)（MIT License）で定義されている action lines を body に記録します。

## コミット形式

```
type(scope): subject line

action-type(scope): description
action-type(scope): description
```

### action types

必要なものだけ使用する。

| type | 意味 | 使いどころ |
|------|------|-----------|
| `intent(scope)` | ユーザーが求めた目的・理由 | 動機が subject から自明でない場合 |
| `decision(scope)` | 複数の選択肢から選んだ理由 | 代替案を検討した場合 |
| `rejected(scope)` | 却下した選択肢と理由（**必ず理由を記載**） | 将来同じ提案を防ぐために高価値 |
| `constraint(scope)` | 実装を制約したハード制限 | 非自明な制約があった場合 |
| `learned(scope)` | 将来役立つ発見・API の挙動 | 「事前に知りたかった」事項 |

### ルール

- action lines は省略可（typo 修正や依存関係バンプは subject だけで十分）
- diff から明らかな内容は書かない
- `rejected` には必ず理由を記載
- セッション内で把握していない変更には `decision` のみ推論可
  - `intent` / `rejected` / `constraint` / `learned` は推測不可

## 実行フロー

1. 現在の変更状態を確認（並列実行）
   - `jj st` で変更されたファイルを確認
   - `jj diff --stat` で変更の概要を確認
   - `jj log -n 5` で過去のコミット説明の形式と scope の命名を確認

2. 変更内容を分析
   - `jj diff` で各ファイルの差分を確認
   - 変更の種類を特定（feat, fix, refactor など）
   - セッション内の文脈から intent / decision / rejected / constraint / learned を収集

3. コミット説明を生成
   - Conventional Commits 形式で subject line を記述
   - signal のある action lines のみ body に追加
   - 過去のコミットで使われた scope 名に揃える

4. ユーザーに確認
   - 生成した説明文を提示
   - 承認を得る

5. コミット説明を更新
   - `jj desc -m "..."` で説明を更新

## 注意事項

- `jj st` / `jj diff --stat` / `jj log -n 5` は並列実行可
- ユーザーの承認を得てから `jj desc` を実行すること
- `jj commit` `jj new` はユーザーが実行するため呼び出さない
