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

override が要るかどうかは「base が Git 管理下にあり `chezmoi apply` のたびに再生成されるファイルか」で決まる。

### base ファイルに部分的に upsert したい場合

`.claude/settings.json`, vscode の `settings.json`/`keybindings.json`, `.config/zed/{settings,keymap}.json`,
`.config/{herdr,mise}/config.toml`, `.config/ghostty/config`, `.config/git/ignore`, `.config/pnpm/rc`,
`.config/uv/uv.toml`, `.config/.bunfig.toml`, `.config/pnpm/config.yaml`, `.npmrc` は
すべて chezmoi が毎回 base から再生成するので、直接編集しても次の apply で消える。これらは
`~/.config/chezmoi-overrides/` 配下（このリポジトリの外・Git 管理対象外）に `$HOME` から見た相対パスと
同じ構造で override ファイルを置くと、次の `chezmoi apply` から自動的に反映される。ファイルが無ければ
base の内容がそのまま使われる。profile（personal/work）のようなプロンプトへの回答は不要

`.config/jj/config.toml` はコメントや複数行文字列が多く、構造化マージ（`fromToml`→`toToml`）を通すと
コメントが消え整形も崩れるため、あえて override 非対応の `symlink_` のまま残している
（直接編集は可能。GUI からの編集も repo にそのまま反映される）。`.config/zoxide/.zoxide.nu` も
zoxide コマンドが自動生成する内容で人間が編集しないため、同様に override 非対応のままにしている。

例: `mise` の `node` バージョンだけ会社PCで変えたい場合

```sh
mkdir -p ~/.config/chezmoi-overrides/.config/mise
cat <<'EOF' > ~/.config/chezmoi-overrides/.config/mise/config.toml
[tools]
node = "20"
EOF
chezmoi apply
```

JSON/TOML/YAML はキー単位マージ（`mergeOverwrite`）、プレーンテキストは base への末尾追記で合成される。
新しいファイルをこの upsert に対応させたい場合は `chezmoi/.chezmoitemplates/merge-config`
（JSON/TOML 用）または `chezmoi/.chezmoitemplates/append-config`（プレーンテキスト用）を
`chezmoi/<対象パス>.tmpl` から `{{ template "merge-config" (dict "BasePath" ... "OverridePath" ... "Format" ...) }}`
の形で呼び出す。

### base に存在しない新規ファイルを会社PCだけに置きたい場合

`chezmoi apply` は source tree にあるものしか触らないので、そもそも chezmoi が関知しないパスは
**直接その場所にファイルを作れば十分**。override の仕組みは不要。

例: 会社PCだけで使う agent skill

```sh
mkdir -p ~/.agents/skills/company-tool
cp SKILL.md ~/.agents/skills/company-tool/SKILL.md
```

`chezmoi/agent-skills/*` が Claude Code と Codex の共通 SSOT である。`chezmoi apply` は
`~/.claude/skills` と `~/.agents/skills` に skill ごとの symlink を作成する
（`chezmoi/run_after_sync-agent-skills.sh.tmpl` が管理）。Git 管理外の skill は、repo の skill 名と
衝突しない限り、どちらのディレクトリに直接追加しても消えたり上書きされたりしない。
