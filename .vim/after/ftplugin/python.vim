if exists('b:did_ftplugin_python')
  finish
endif
let b:did_ftplugin_python = 1

let s:python_path = system('python -', 'import sys;sys.stdout.write(",".join(sys.path))')

py3 << EOF
import os
import sys
import vim

python_paths = vim.eval('s:python_path').split(',')
for path in python_paths:
    if not path in sys.path:
        sys.path.insert(0, path)
EOF
" 構文チェックの設定
let g:syntastic_python_checkers = ["pep8"]

setlocal colorcolumn=80 "80列目にラインを入れる
setlocal tabstop=4 "インデントをスペース4つ分に設定
setlocal shiftwidth=4 "自動インデントの幅
setlocal smartindent "オートインデント
setlocal smarttab "新しい行を作った時に高度な自動インデント

"#####python設定#####
setlocal omnifunc=pythoncomplete#Complete
if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
" let g:neocomplete#force_omni_input_patterns.python = '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
let g:neocomplete#force_omni_input_patterns.python = '\h\w*\|[^. \t]\.\w*'
