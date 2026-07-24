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
        {
            name: edit_command_in_editor
            modifier: control
            keycode: char_g
            mode: [emacs, vi_normal, vi_insert]
            event: {
                send: executehostcommand
                cmd: "edit-command-in-editor"
            }
        }
    ]
    datetime_format: {
        normal: "%+"
        table: "%+"
    }
}

# --- utility modules ----------------------------------------------------------
# 用途が明確なユーティリティは scripts/ 配下のモジュールに分けている。
# 実体は home/shell/nushell/scripts/*.nu で、home-manager が
# ~/.config/nushell/scripts へリンクする。相対パスは config.nu の実体
# (nix store) ではなくシンボリックリンクの置かれた ~/.config/nushell/ を
# 基準に解決される。
#
# 名前空間を切るかどうかはモジュールごとに選ぶ:
#   `use x.nu`   … 体系が複雑で `k8s <Tab>` で引きたいもの
#   `use x.nu *` … 単体で意味が通る名前のもの (フラットに取り込む)
# どちらでも export しない def は private のままになる。
use ./scripts/grpc.nu     # grpc curl (buf curl ラッパー)
use ./scripts/k8s.nu      # k8s pods-restarts / pods-running / pods-top-mem / svc-lbs / deploys-unready / nodes-arch
use ./scripts/k8s.nu kg   # kg = kubectl get ... -o json | from json | get items
use ./scripts/fs.nu *     # du-top / find-large / find-recent
use ./scripts/http.nu *   # urlencode
use ./scripts/port.nu *   # port-using / port-listening / port-kill

# zoxide path copy (interactive)
def zp [...rest: string] {
  zoxide query --interactive -- ...$rest | str trim -r -c "\n" | pbcopy
}

# ghq path copy (interactive)
def zgp [] {
  ghq list --full-path | fzf | str trim | pbcopy
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

# --- edit command line in $EDITOR (Ctrl-G) -----------------------------------

# Edit the current command line buffer in $env.EDITOR, then replace the
# buffer with the edited result (bound to Ctrl-G).
def edit-command-in-editor [] {
  let tmp = (mktemp --suffix ".nu")
  commandline | save --force $tmp
  ^$env.EDITOR $tmp
  let edited = (open --raw $tmp | str trim --right --char (char nl))
  rm $tmp
  commandline edit --replace $edited
}

source ~/.config/zoxide/.zoxide.nu
