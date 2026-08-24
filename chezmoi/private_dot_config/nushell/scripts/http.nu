# HTTP / URL 関連のヘルパー。
#
# 単体で意味が通る名前なので、config.nu からは `use ./scripts/http.nu *` で
# フラットに取り込む (組み込みの http / url ファミリーには一切触れない)。

# record を application/x-www-form-urlencoded なクエリ文字列に変換する。
#
# 組み込みの `url build-query` と違い、null の値はスキップし、
# list の値は同じキーを繰り返して展開する。
#
# Example:
#   urlencode {q: "hello world", tag: [a b], skip: null}
#   # => q=hello%20world&tag=a&tag=b
export def urlencode [rec: record] {
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
