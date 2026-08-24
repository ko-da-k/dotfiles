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
- `home.nix` / `home/**` / `extra/**`: Nix パッケージのインストールを管理
- `chezmoi/**`: dotfiles（symlink・テンプレート）の展開を管理
