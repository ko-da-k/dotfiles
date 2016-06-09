py3 << EOF
import os
import sys

path = os.path.expanduser("~/.pyenv/versions/anaconda-2.3.0/lib/python2.7/site-packages")
if not path in sys.path:
    sys.path.append(path)
EOF

"---------------------------------------------------------------------------
" For jedi-vim
"setlocal omnifunc=jedi#completions
"let g:jedi#completions_enabled = 0
"let g:jedi#auto_vim_configuration = 0

"---------------------------------------------------------------------------
" 構文チェックの設定
let g:syntastic_python_checkers = ["flake8"]

set colorcolumn=80 "80行目にラインを入れる
