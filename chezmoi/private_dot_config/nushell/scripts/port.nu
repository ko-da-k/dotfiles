# TCP ポートを握っているプロセスを調べる / 落とすためのヘルパー (macOS lsof)。
#
# 組み込みに `port` コマンドがあるため名前空間は切らず、config.nu からは
# `use ./scripts/port.nu *` でフラットに取り込む。接頭辞は名前自体に持たせる。

# lsof の出力行を {cmd, pid, user, addr} の table に整形する。
def parse-lsof [res: record]: nothing -> table {
  if $res.exit_code != 0 {
    return []
  }
  $res.stdout
  | lines
  | skip 1
  | each { |line|
      let parts = ($line | split row -r '\s+')
      {
        cmd: ($parts | get 0)
        pid: ($parts | get 1)
        user: ($parts | get 2)
        addr: ($parts | get 8)
      }
    }
}

# 指定した TCP ポートを LISTEN しているプロセス一覧。
#
# Example:
#   port-using 8080
export def port-using [port: int]: nothing -> table {
  parse-lsof (^lsof +c 0 -nP $"-iTCP:($port)" -sTCP:LISTEN | complete)
}

# LISTEN 状態の TCP ポートをすべて列挙する。
#
# Example:
#   port-listening
export def port-listening []: nothing -> table {
  parse-lsof (^lsof +c 0 -nP -iTCP -sTCP:LISTEN | complete)
}

# 指定した TCP ポートのプロセスに SIGTERM (--force で SIGKILL) を送る。
#
# Example:
#   port-kill 8080
#   port-kill 8080 --force
export def port-kill [
  port: int
  --force
] {
  let pids = (port-using $port | get pid? | default [])
  if ($pids | is-empty) {
    print $"no process listening on port ($port)"
    return
  }
  let signal = if $force { "-KILL" } else { "-TERM" }
  $pids | each { |pid|
    print $"kill ($signal) ($pid)"
    ^kill $signal $pid
  } | ignore
}
