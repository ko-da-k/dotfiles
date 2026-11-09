# dotfiles

## Setup

1. Nix をインストールする
2. `make switch` — home-manager が chezmoi を含む必要なツールをインストールする
3. `chezmoi init --apply --source .`（このリポジトリの `chezmoi/` を source として使う。
   `.chezmoiroot` で source directory がこのリポジトリ直下、実体は `chezmoi/` 以下と定義されている）
   - 初回のみ `profile`（personal/work）を尋ねられる。回答は `~/.config/chezmoi/chezmoi.toml`
     （このリポジトリの外・Git 管理対象外）に保存される
   - 2回目以降の反映は `chezmoi apply` のみでよい
4. `mise install` — Nushell と language toolchain をインストールする

パッケージのインストール（Nix/home-manager）と dotfiles の展開（chezmoi）は責務が分かれている。
- `home.nix` / `home/**`: Nix パッケージのインストールを管理
- `chezmoi/**`: dotfiles（symlink・テンプレート）の展開を管理

## Nushell

Nushell 本体は Home Manager ではなく、`chezmoi/base/.config/mise/config.toml` の
`aqua:nushell/nushell` でバージョンを管理する。バージョンを更新したら設定を反映してインストールする。

```sh
chezmoi apply
mise install
```

`config.nu` は `chezmoi/base/.config/nushell/config.nu` に置く。

## herdr plugin

`herdr-plugins/` の plugin は chezmoi で配置せず、`herdr plugin link` で登録する。
`chezmoi apply` が manifest の変更時に link する（`chezmoi/run_onchange_after_link-herdr-plugins.sh.tmpl`）。

- `agent-name`: agent の起動時に、名前が未設定なら名前を入力する popup を出す。
  `prefix+shift+a` でフォーカス中の agent の名前を変更する

## マシン固有の設定

### ツールの設定分割機能を使う

base は `symlink_` で配置し、マシン固有の設定は Git 管理外のファイルに書く。

| ツール | マシン固有の設定 | 読み込み |
|---|---|---|
| jj | `~/.config/jj/conf.d/*.toml` | キー単位でマージ |
| mise | `~/.config/mise/conf.d/*.toml` | キー単位でマージ |
| nushell | `~/.config/nushell/autoload/*.nu` | `config.nu` の後に実行 |
| ghostty | `~/.config/ghostty/config.local` | base の後に読み込み |

`mise use -g` などでツールが設定を書き換えると、repo の base が変わる。

```sh
# 例: 会社PCだけ node のバージョンを変える
mkdir -p ~/.config/mise/conf.d
cat <<'EOF' > ~/.config/mise/conf.d/local.toml
[tools]
node = "20"
EOF
```

### chezmoi-overrides を使う

設定分割に対応していないツールは、chezmoi が base と override を合成してファイルを生成する。
生成されたファイルを直接編集しても、次の `chezmoi apply` で上書きされる。

対象: `.claude/settings.json`, VS Code の `settings.json`/`keybindings.json`,
`.config/zed/{settings,keymap}.json`, `.config/herdr/config.toml`, `.config/git/ignore`,
`.config/pnpm/{rc,config.yaml}`, `.config/uv/uv.toml`, `.config/.bunfig.toml`, `.npmrc`

`~/.config/chezmoi-overrides/` に `$HOME` からの相対パスでファイルを置くと、`chezmoi apply` で合成される。

- JSON/TOML/YAML: キー単位でマージ（`chezmoi/.chezmoitemplates/merge-config`）
- プレーンテキスト: base の末尾に追記（`chezmoi/.chezmoitemplates/append-config`）

対象を増やすときは `chezmoi/<対象パス>.tmpl` から上記のテンプレートを呼ぶ。

### base にないファイル

chezmoi は source にないパスを管理しないので、直接置けばよい。

```sh
# 例: 会社PCだけで使う agent skill
mkdir -p ~/.agents/skills/company-tool
cp SKILL.md ~/.agents/skills/company-tool/SKILL.md
```

`chezmoi/agent-skills/*` は Claude Code と Codex で共有する。`chezmoi apply` が
`~/.claude/skills` と `~/.agents/skills` に skill ごとの symlink を作る
（`chezmoi/run_after_sync-agent-skills.sh.tmpl`）。repo の skill と名前が重ならなければ、
直接置いた skill は消えない。
