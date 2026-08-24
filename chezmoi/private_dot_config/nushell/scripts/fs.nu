# ファイルシステムの調査ヘルパー (容量の大きいもの / 最近触ったものを探す)。
#
# 単体で意味が通る名前なので、config.nu からは `use ./scripts/fs.nu *` で
# フラットに取り込む。

# 深さ1のエントリを物理サイズ順に上位 N 件表示する (既定: カレント / 10件)。
#
# Example:
#   du-top
#   du-top ./src --limit 5
export def du-top [
  path: string = "."
  --limit (-n): int = 10
]: nothing -> table {
  du --all ($"($path)/*" | into glob)
  | sort-by physical --reverse
  | first $limit
  | select path apparent physical
}

# --path 配下で --min より大きいファイルを探す (既定: 100 MB / カレント)。
#
# Example:
#   find-large
#   find-large --min 1GB --path ./node_modules
export def find-large [
  --min: filesize = 100MB
  --path: string = "."
]: nothing -> table {
  ls ($"($path)/**/*" | into glob)
  | where type == file and size >= $min
  | sort-by size --reverse
  | select name size
}

# 直近 --days 日以内に更新されたファイルを探す (既定: 7日)。
#
# Example:
#   find-recent
#   find-recent --days 1 --path ./src
export def find-recent [
  --days: int = 7
  --path: string = "."
]: nothing -> table {
  let cutoff = ((date now) - ($days * 1day))
  ls ($"($path)/**/*" | into glob)
  | where type == file and modified >= $cutoff
  | sort-by modified --reverse
  | select name size modified
}
