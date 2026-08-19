{ pkgs, ... }:

{
  # シェル横断で使うコマンド。zsh 関数だと zsh のプロセス内にしか存在せず、
  # nushell や fish から呼べないので、PATH 上の実行ファイルとして入れる。
  home.packages = [
    # shebang は bash ではなく zsh。中身が emulate / setopt err_return /
    # ${match} / ${(q)} / ${x:h} といった zsh 固有の機能に依存している。
    (pkgs.writeScriptBin "pr-review" ''
      #!${pkgs.zsh}/bin/zsh
      ${builtins.readFile ./pr-review.zsh}
      pr-review "$@"
    '')
  ];
}
