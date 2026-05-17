$env.STARSHIP_SHELL = "nu"

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=$($env.LAST_EXIT_CODE)'
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = "> "
$env.PROMPT_INDICATOR_VI_NORMAL = "V "
$env.PROMPT_MULTILINE_INDICATOR = "... "

$env.config = {
edit_mode: "vi"
history: {
    max_size: 10000
}
keybindings: [
    {
        name: nu_history_search
        modifier: control
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "nu-history-replace"
        }
    }
    {
        name: zsh_history_search
        modifier: alt
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "zsh-history-replace"
        }
    }
]
}

def urlencode [rec: record] {
    mut pairs = []
    for key in ($rec | columns) {
        let value = ($rec | get $key)
        if $value == null {
        continue
        }
        let key_encoded = ($key | url encode)
        match ($value | describe | str replace --regex "<.*" "") {
        "list" => {
            for item in $value {
            let item_encoded = ($item | into string | url encode)
            $pairs = ($pairs | append $"($key_encoded)=($item_encoded)")
            }
        }
        _ => {
            let value_encoded = ($value | into string | url encode)
            $pairs = ($pairs | append $"($key_encoded)=($value_encoded)")
        }
        }
    }
    $pairs | str join "&"
}

# zoxide path copy (interactive)
def zp [...rest: string] {
  zoxide query --interactive -- ...$rest | str trim -r -c "\n" | pbcopy
}

# ghq path copy (interactive)
def zgp [] {
  ghq list --full-path | fzf | str trim | pbcopy
}

# --- port / process helpers ---------------------------------------------------

# Show processes LISTENing on the given TCP port (macOS lsof).
#
# Example:
#   port-using 8080
def port-using [port: int]: nothing -> table {
  let res = (^lsof +c 0 -nP $"-iTCP:($port)" -sTCP:LISTEN | complete)
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

# All TCP ports currently in LISTEN state (macOS lsof).
#
# Example:
#   listening-ports
def listening-ports []: nothing -> table {
  let res = (^lsof +c 0 -nP -iTCP -sTCP:LISTEN | complete)
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

# Send SIGTERM (or SIGKILL with --force) to processes on the given TCP port.
#
# Example:
#   kill-port 8080
#   kill-port 8080 --force
def kill-port [
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

# --- filesystem helpers -------------------------------------------------------

# Top N entries by physical size at depth 1 (default current dir, top 10).
#
# Example:
#   du-top
#   du-top ./src --limit 5
def du-top [
  path: string = "."
  --limit (-n): int = 10
]: nothing -> table {
  du --all ($"($path)/*" | into glob)
  | sort-by physical --reverse
  | first $limit
  | select path apparent physical
}

# Files larger than --min under --path (defaults: 100 MB / current dir).
#
# Example:
#   find-large
#   find-large --min 1GB --path ./node_modules
def find-large [
  --min: filesize = 100MB
  --path: string = "."
]: nothing -> table {
  ls ($"($path)/**/*" | into glob)
  | where type == file and size >= $min
  | sort-by size --reverse
  | select name size
}

# Files modified within the last --days days (default 7).
#
# Example:
#   find-recent
#   find-recent --days 1 --path ./src
def find-recent [
  --days: int = 7
  --path: string = "."
]: nothing -> table {
  let cutoff = ((date now) - ($days * 1day))
  ls ($"($path)/**/*" | into glob)
  | where type == file and modified >= $cutoff
  | sort-by modified --reverse
  | select name size modified
}

# --- kubectl helpers ----------------------------------------------------------
# Each helper takes the parsed `kubectl get ... -o json | from json` record via
# pipeline input, so the caller controls namespace / selectors / etc.

# Aggregate pod restart counts and sort by total restarts (desc).
#
# Example:
#   kubectl get pods -n kube-system -o json | from json | kpods_restarts
def kpods_restarts []: record -> table {
  $in
  | get items
  | each {
      let statuses = ($in.status.containerStatuses? | default [])
      let restarts = (
        $statuses
        | each { $in.restartCount? | default 0 }
        | math sum
      )
      { name: $in.metadata.name, restarts: $restarts }
    }
  | sort-by restarts --reverse
}

# List pods in the Running phase with namespace / name / podIP.
#
# Example:
#   kubectl get pods -A -o json | from json | kpods_running
def kpods_running []: record -> table {
  $in
  | get items
  | where status.phase == "Running"
  | select metadata.namespace metadata.name status.podIP
}

# Top 5 pods by sum of container memory requests.
#
# Example:
#   kubectl get pods -A -o json | from json | kpods_top_mem
def kpods_top_mem []: record -> table {
  $in
  | get items
  | each {|pod|
      let mems = ($pod.spec.containers
          | default []
          | each {|c|
              $c
              | get -o resources.requests.memory
              | default "0"
              | str replace -a 'Ki' 'KiB'
              | str replace -a 'Mi' 'MiB'
              | str replace -a 'Gi' 'GiB'
              | str replace -a 'Ti' 'TiB'
              | into filesize
          })
      {
        namespace: $pod.metadata.namespace,
        name: $pod.metadata.name,
        mem_request: ($mems | math sum)
      }
    }
  | sort-by mem_request --reverse
  | first 5
}

# List LoadBalancer services with externalIPs and ports.
#
# Example:
#   kubectl get svc -A -o json | from json | ksvc_lbs
def ksvc_lbs []: record -> table {
  $in
  | get items
  | where spec.type == "LoadBalancer"
  | select metadata.namespace metadata.name spec.externalIPs spec.ports
}

# Deployments whose ready replicas < desired replicas.
#
# Example:
#   kubectl get deploy -A -o json | from json | kdeploys_unready
def kdeploys_unready []: record -> table {
  $in
  | get items
  | each {
      {
        namespace: $in.metadata.namespace,
        name: $in.metadata.name,
        ready: ($in.status.readyReplicas? | default 0 | into int),
        replicas: ($in.status.replicas? | default 0 | into int)
      }
    }
  | where { $in.ready < $in.replicas }
  | select namespace name ready replicas
  | sort-by namespace name
}

# Node name and CPU architecture.
#
# Example:
#   kubectl get nodes -o json | from json | knodes_arch
def knodes_arch []: record -> table {
  $in
  | get items
  | select metadata.name status.nodeInfo.architecture
}

# --- buf curl wrapper --------------------------------------------------------
# nushell 用 buf curl ラッパー。
#
# - body はパイプ入力 / --body / --body-file から受け取り、`buf curl -d @-` に流す:
#     record       → 1 メッセージ (Unary / Server streaming)
#     list<record> → 複数メッセージ (Client / Bidi streaming)
#     string       → そのまま (NDJSON 文字列も可)
#     nothing      → ボディ無し
# - 既定では構造化データを返す (Unary は record、streaming は list<record>)。
#   --raw で常に list を強制。--full で http status / headers / trailers を
#   含む record を返す (`http get --full` 相当)。
# - 任意のフラグは --opts (list<string>) で透過的に渡せる。
#
# Example:
#   {name: "Alice"} | buf-curl --h2c http://localhost:50051/foo.v1.Foo/Bar
#   [{name: A} {name: B}] | buf-curl --h2c $url
#   {name: "Alice"} | buf-curl --h2c --full $url

# 内部用: `Name: Value` 形式の文字列 list を record に変換
def _bufcurl-headers-to-record [headers: list<string>]: nothing -> record {
    $headers | reduce --fold {} {|line, acc|
        let pair = ($line | split row --number 2 ":")
        if ($pair | length) == 2 {
            $acc | upsert ($pair | get 0 | str trim) ($pair | get 1 | str trim)
        } else {
            $acc
        }
    }
}

# 内部用: buf curl -v の stderr を解析して
# {http_status, grpc_status, grpc_message, headers, trailers} を返す
def _bufcurl-parse-verbose [stderr: string]: nothing -> record {
    let lines = (
        $stderr
        | lines
        | each {|l| $l | str replace --regex '^buf:\s*' '' }
    )

    mut req_hdr = []
    mut resp_hdr = []
    mut trailers = []
    mut http_status = null
    mut phase = "req-header"   # req-header -> resp-header -> resp-body -> trailer

    for line in $lines {
        let parsed = ($line | parse --regex '^(?P<sigil>[<>{}*])\s*\(#\d+\)\s*(?P<content>.*)$')
        if ($parsed | is-empty) { continue }
        let row = ($parsed | first)
        let sigil = $row.sigil
        let content = $row.content

        if $sigil == ">" {
            if $content == "" { continue }
            if ($content | str starts-with "POST ") or ($content | str starts-with "GET ") or ($content | str starts-with "PUT ") {
                continue
            }
            $req_hdr = ($req_hdr | append $content)
        } else if $sigil == "<" {
            if $content == "" {
                $phase = (match $phase {
                    "resp-header" => "resp-body"
                    "resp-body" => "trailer"
                    _ => $phase
                })
                continue
            }
            if ($content | str starts-with "HTTP/") {
                $http_status = $content
                $phase = "resp-header"
                continue
            }
            if $phase == "trailer" {
                $trailers = ($trailers | append $content)
            } else {
                $resp_hdr = ($resp_hdr | append $content)
            }
        }
    }

    let req_hdrs = (_bufcurl-headers-to-record $req_hdr)
    let resp_hdrs = (_bufcurl-headers-to-record $resp_hdr)
    let trailer_hdrs = (_bufcurl-headers-to-record $trailers)

    let status_str = ($http_status | default "")
    let http_code = (
        if ($status_str | is-empty) { null } else {
            let m = ($status_str | parse --regex 'HTTP/[\d.]+\s+(?P<code>\d+)')
            if ($m | is-empty) { null } else { $m | first | get code | into int }
        }
    )

    let grpc_status = (
        if "Grpc-Status" in $trailer_hdrs {
            $trailer_hdrs | get "Grpc-Status" | into int
        } else { null }
    )

    {
        http_status: $http_code,
        grpc_status: $grpc_status,
        grpc_message: ($trailer_hdrs | get --optional "Grpc-Message"),
        headers: { request: $req_hdrs, response: $resp_hdrs },
        trailers: $trailer_hdrs,
    }
}

# 内部用: buf curl の pretty-printed JSON 出力 (`}\n{` 区切り) を list<record> に
def _bufcurl-parse-body [text: string]: nothing -> list {
    let trimmed = ($text | str trim)
    if ($trimmed | is-empty) {
        []
    } else {
        let joined = ($trimmed | str replace --all "}\n{" "},{")
        ("[" + $joined + "]") | from json
    }
}

# Example:
#   {name: "Alice"} | buf-curl --h2c http://localhost:50051/greet.v1.GreetService/SayHello
#   [{name: A} {name: B}] | buf-curl --h2c $url
#   {name: "Alice"} | buf-curl --h2c --full $url
def buf-curl [
    url: string                              # http(s)://host:port/package.Service/Method
    --schema: string = "proto"               # proto ディレクトリ / BSR module 等
    --protocol: string = "grpc"              # grpc / grpc-web / connect
    --h2c                                    # 平文 HTTP/2 (--http2-prior-knowledge)
    --reflect                                # サーバー reflection を使う (--schema と排他)
    --body: any                              # ボディを直接指定 (パイプ入力より優先)
    --body-file: path                        # ボディをファイルから読む
    --opts: list<string> = []                # buf curl に追加で渡すフラグ
    --raw                                    # body を常に list で返す
    --full                                   # status / headers / trailers を含む record を返す
]: [
    nothing -> any
    string -> any
    record -> any
    list -> any
] {
    let piped = $in
    let body_value = if ($body | describe) != "nothing" {
        $body
    } else if ($body_file | is-not-empty) {
        open --raw $body_file
    } else {
        $piped
    }

    let body_text = match ($body_value | describe --detailed | get type) {
        "nothing" => null
        "string"  => $body_value
        "record"  => ($body_value | to json --raw)
        "list"    => ($body_value | each {|m| $m | to json --raw } | str join "\n")
        _         => ($body_value | to json --raw)
    }

    mut flags = []
    if $reflect {
        $flags = ($flags | append ["--reflect"])
    } else {
        $flags = ($flags | append ["--schema" $schema])
    }
    $flags = ($flags | append ["--protocol" $protocol])
    if $h2c { $flags = ($flags | append ["--http2-prior-knowledge"]) }
    if $full { $flags = ($flags | append ["-v"]) }
    $flags = ($flags | append $opts)

    let result = if $body_text == null {
        ^buf curl ...$flags $url | complete
    } else {
        $body_text | ^buf curl ...$flags -d "@-" $url | complete
    }

    let parsed = (_bufcurl-parse-body $result.stdout)
    let body = if $raw or ($parsed | length) != 1 {
        $parsed
    } else {
        $parsed | first
    }

    if not $full {
        return $body
    }

    let meta = (_bufcurl-parse-verbose $result.stderr)
    {
        http_status: $meta.http_status,
        grpc_status: $meta.grpc_status,
        grpc_message: $meta.grpc_message,
        headers: $meta.headers,
        trailers: $meta.trailers,
        body: $body,
        exit_code: $result.exit_code,
    }
}

# --- nushell history search (Ctrl-R) -----------------------------------------

# Pick a previous nushell command via fzf and return it as a string.
def nu-history-search [] {
  try {
    history
    | get command
    | reverse
    | uniq
    | str join (char nl)
    | fzf --no-sort --height 40% --reverse
    | str trim
  } catch {
    ""
  }
}

# Replace the current prompt with a nushell history pick (bound to Ctrl-R).
def nu-history-replace [] {
  let cmd = (nu-history-search)
  if ($cmd | is-not-empty) {
    commandline edit --replace $cmd
  }
}

# --- zsh history search (Alt-R) ----------------------------------------------

# Pick a previous zsh command via fzf and return it as a string.
# Strips extended_history `: <ts>:<elapsed>;` prefix and dedupes (newest first).
def zsh-history-search [] {
  try {
    ^cat ~/.zsh_history
    | lines
    | each { |l| $l | str replace --regex '^: \d+:\d+;' '' }
    | reverse
    | uniq
    | str join (char nl)
    | fzf --no-sort --height 40% --reverse
    | str trim
  } catch {
    ""
  }
}

# Replace the current prompt with a zsh history pick (bound to Alt-R).
def zsh-history-replace [] {
  let cmd = (zsh-history-search)
  if ($cmd | is-not-empty) {
    commandline edit --replace $cmd
  }
}

source ~/.config/zoxide/.zoxide.nu
