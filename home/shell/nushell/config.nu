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
    name: fuzzy_history
    modifier: control
    keycode: char_r
    mode: [emacs, vi_normal, vi_insert]
    event: [
        {
        send: ExecuteHostCommand
        cmd: "commandline edit --insert (
            history 
            | get command
            | uniq 
            | reverse 
            | str join (char -i 0) 
            | fzf --read0 --no-sort --height=40% -q (commandline) 
            | decode utf-8 
            | str trim
        )"
        }
    ]
    }
]
}

def zsh_history [] {
    commandline edit --insert (
        cat $"($env.HOME)/.zsh_history"
        | lines 
        | uniq 
        | reverse 
        | str join (char -i 0) 
        | fzf --read0 --no-sort --height=40% -q (commandline) 
        | decode utf-8 
        | str trim
    )
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
