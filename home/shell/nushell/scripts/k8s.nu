# kubectl の JSON 出力を nushell のデータとして扱うヘルパー。
#
#   use ./scripts/k8s.nu   # config.nu 側で読み込み済み
#
# 取得は `kg` (フラット)、集計は `k8s <resource>-<観点>` に分かれている。
# namespace / selector などの指定は呼び出し側の kubectl フラグに任せる。
#
# 集計側は `kg` が返す table と、従来どおり
# `kubectl get ... -o json | from json` した record のどちらでも受け取れる。

# 集計コマンドの入力を正規化する。
# `kg` は items を開いた table を返すが、`kubectl ... | from json` は
# items を内包した record を返すため、後者なら items を取り出す。
# items が空 list のケースがあるので、値ではなくキーの有無で判定する。
def unwrap-items []: any -> table {
  let v = $in
  if (($v | describe | str starts-with "record") and ("items" in ($v | columns))) {
    $v.items
  } else {
    $v
  }
}

# kubectl get の結果を nushell のデータとして受け取る。
# `-o json | from json | get items` を毎回書かずに済ませるだけのラッパー。
# フラグはそのまま kubectl get に渡る (-A / -n / -l / --field-selector など)。
#
# 名前空間を切らずフラットに使うため、config.nu 側では
# `use ./scripts/k8s.nu kg` で個別に取り込む。
# (`get` という名前にすると、モジュール内の無修飾 `get` がすべてこちらに
#  解決されてしまい `get -o` や `get items` が壊れる)
#
# Example:
#   kg po -A
#   kg po -A | where status.phase != "Running"
#   kg po -n kube-system | k8s pods-restarts
#   kg ns default | get status.phase
export def --wrapped kg [...rest] {
  ^kubectl get ...$rest -o json | from json | unwrap-items
}

# Pod の restart 回数を合計し、多い順に並べる。
#
# Example:
#   kg pods -n kube-system | k8s pods-restarts
export def pods-restarts []: any -> table {
  $in
  | unwrap-items
  | each {
      let statuses = ($in.status.containerStatuses? | default [])
      # `each` の結果が空だと `math sum` は 0 ではなく空 record を返し
      # (列ゼロのテーブル合計として扱われる)、sort-by が数値より上に並べて
      # しまうため、空のときは明示的に 0 を返す。
      let restarts = (
        if ($statuses | is-empty) { 0 } else {
          $statuses
          | each { $in.restartCount? | default 0 }
          | math sum
        }
      )
      { name: $in.metadata.name, restarts: $restarts }
    }
  | sort-by restarts --reverse
}

# Running フェーズの Pod を namespace / name / podIP で一覧する。
#
# Example:
#   kg pods -A | k8s pods-running
export def pods-running []: any -> table {
  $in
  | unwrap-items
  | where status.phase == "Running"
  | select metadata.namespace metadata.name status.podIP
}

# コンテナの memory request 合計が大きい Pod 上位5件。
#
# Example:
#   kg pods -A | k8s pods-top-mem
export def pods-top-mem []: any -> table {
  $in
  | unwrap-items
  | each {|pod|
      # `?` が無いと containers キー欠落時に `| default []` へ届く前に
      # column_not_found で落ちる (pods-restarts の containerStatuses? と同じ)
      let mems = ($pod.spec.containers?
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
        # pods-restarts と同じ理由で空のときは 0b を返す
        mem_request: (if ($mems | is-empty) { 0b } else { $mems | math sum })
      }
    }
  | sort-by mem_request --reverse
  | first 5
}

# LoadBalancer タイプの Service を externalIP / port つきで一覧する。
#
# Example:
#   kg svc -A | k8s svc-lbs
export def svc-lbs []: any -> table {
  $in
  | unwrap-items
  | where spec.type == "LoadBalancer"
  | select metadata.namespace metadata.name spec.externalIPs spec.ports
}

# ready replica 数が desired に届いていない Deployment。
#
# Example:
#   kg deploy -A | k8s deploys-unready
export def deploys-unready []: any -> table {
  $in
  | unwrap-items
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

# Node 名と CPU アーキテクチャ。
#
# Example:
#   kg nodes | k8s nodes-arch
export def nodes-arch []: any -> table {
  $in
  | unwrap-items
  | select metadata.name status.nodeInfo.architecture
}
