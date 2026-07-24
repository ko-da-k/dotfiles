# nushell 用 buf curl ラッパー。
#
#   use ./scripts/grpc.nu   # config.nu 側で読み込み済み
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

# `Name: Value` 形式の文字列 list を record に変換
def headers-to-record [headers: list<string>]: nothing -> record {
    $headers | reduce --fold {} {|line, acc|
        let pair = ($line | split row --number 2 ":")
        if ($pair | length) == 2 {
            $acc | upsert ($pair | get 0 | str trim) ($pair | get 1 | str trim)
        } else {
            $acc
        }
    }
}

# buf curl -v の stderr を解析して
# {http_status, grpc_status, grpc_message, headers, trailers} を返す
def parse-verbose [stderr: string]: nothing -> record {
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

    let req_hdrs = (headers-to-record $req_hdr)
    let resp_hdrs = (headers-to-record $resp_hdr)
    let trailer_hdrs = (headers-to-record $trailers)

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

# buf curl の pretty-printed JSON 出力 (`}\n{` 区切り) を list<record> に
def parse-body [text: string]: nothing -> list {
    let trimmed = ($text | str trim)
    if ($trimmed | is-empty) {
        []
    } else {
        let joined = ($trimmed | str replace --all "}\n{" "},{")
        ("[" + $joined + "]") | from json
    }
}

# Example:
#   {name: "Alice"} | grpc curl --h2c http://localhost:50051/greet.v1.GreetService/SayHello
#   [{name: A} {name: B}] | grpc curl --h2c $url
#   {name: "Alice"} | grpc curl --h2c --full $url
export def curl [
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

    let parsed = (parse-body $result.stdout)
    let body = if $raw or ($parsed | length) != 1 {
        $parsed
    } else {
        $parsed | first
    }

    if not $full {
        return $body
    }

    let meta = (parse-verbose $result.stderr)
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
