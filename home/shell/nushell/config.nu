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
