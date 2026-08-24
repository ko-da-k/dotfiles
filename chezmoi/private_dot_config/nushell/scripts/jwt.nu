export def deccode [token: string] {
  let parts = ($token | split row ".")
  {
    headers: (pad ($parts | get 0) | decode base64 --url | decode utf-8 | from json)
    payload: (pad ($parts | get 1) | decode base64 --url | decode utf-8 | from json)
    signature: ($parts | get 2)
  }
}

def pad [s: string] {
  let r = ($s | str length) mod 4
  if $r == 0 {
    $s
  } else {
    $s + ("" | fill --character "=" --width (4 - $r))
  }
}
