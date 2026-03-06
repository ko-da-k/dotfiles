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

source ~/.config/zoxide/.zoxide.nu
source ~/.config/atuin/.atuin.init.nu
