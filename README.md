# dotfiles

## Setup

1. Nix をインストールする
2. `make switch` — home-manager が chezmoi を含む必要なツールをインストールする
3. `chezmoi init --apply --source .`（このリポジトリの `chezmoi/` を source として使う。
   `.chezmoiroot` で source directory がこのリポジトリ直下、実体は `chezmoi/` 以下と定義されている）
   - 初回のみ `profile`（personal/work）を尋ねられる。回答は `~/.config/chezmoi/chezmoi.toml`
     （このリポジトリの外・Git 管理対象外）に保存される
   - 2回目以降の反映は `chezmoi apply` のみでよい

パッケージのインストール（Nix/home-manager）と dotfiles の展開（chezmoi）は責務が分かれている。
- `home.nix` / `home/**`: Nix パッケージのインストールを管理
- `chezmoi/**`: dotfiles（symlink・テンプレート）の展開を管理

## マシンごとの override（会社PCだけ設定を変えたい等）

`~/.config/chezmoi-overrides/` 配下（このリポジトリの外・Git 管理対象外）に、対象ファイルと同じ相対パスで
override ファイルを置くと、次の `chezmoi apply` から自動的に反映される。ファイルが無ければ base の内容が
そのまま使われる。profile（personal/work）のようなプロンプトへの回答は不要。

例: `mise` の `node` バージョンだけ会社PCで変えたい場合

```sh
mkdir -p ~/.config/chezmoi-overrides/dot_config/mise
cat <<'EOF' > ~/.config/chezmoi-overrides/dot_config/mise/config.toml
[tools]
node = "20"
EOF
chezmoi apply
```

対象ファイルとパスの対応、フォーマットごとの合成方法:

| フォーマット | 対応ファイル | 合成方法 |
|---|---|---|
| JSON | `.claude/settings.json`, `Library/Application Support/Code/User/{settings,keybindings}.json`, `.config/zed/{settings,keymap}.json` | キー単位で upsert（`mergeOverwrite`）。JSONC（コメント付き）も可 |
| TOML | `.config/{herdr,mise}/config.toml` | キー単位で upsert（`mergeOverwrite`） |
| プレーンテキスト | `.config/ghostty/config`, `.config/git/ignore`, `.config/pnpm/rc` | base の末尾に override ファイルの内容を追記 |

override パスは `chezmoi-overrides/` 以下、対象ファイルの `dot_`/`private_` を除いた相対パス
（例: `~/.claude/settings.json` → `chezmoi-overrides/dot_claude/settings.json`）。
新しいファイルを override 対応させたい場合は `chezmoi/.chezmoitemplates/merge-config`
（JSON/TOML 用）または `chezmoi/.chezmoitemplates/append-config`（プレーンテキスト用）を
`chezmoi/<対象パス>.tmpl` から `{{ template "merge-config" (dict "BasePath" ... "OverridePath" ... "Format" ...) }}`
の形で呼び出す。
