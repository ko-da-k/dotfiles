## バージョン管理

## Allow

- `jj log` : 履歴確認
- `jj st` : 変更点確認
- `jj diff` : 差分確認
- `jj desc` : 説明の編集
- `jj show` : 変更内容表示
- `jj check` : pre-commit チェック

## Deny

以下の操作はユーザーが実行するため禁止されています。

- `jj commit` : コミット
- `jj bookmark` : ブックマーク
- `jj git push` : リモートへのプッシュ

## Plan の作成フロー

- 実行計画を Plan Mode で作成する場合、1 門 1 答形式で必要な情報をユーザーに訪ね、システム要求を精緻化してください

## Skills

### /jj-desc

jujutsu のコミット説明を自動生成するスキルです。

- 現在の変更内容を分析し、ファイルごとの変更を記述したコミット説明を生成します
- 過去のコミット説明の形式を参考にします
- Conventional Commits 形式（feat, fix, refactor など）で記述します
- 生成後、ユーザーに確認してから `jj desc` で更新します
