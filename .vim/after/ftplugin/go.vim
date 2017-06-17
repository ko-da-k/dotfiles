if exists('b:did_ftplugin_go')
  finish
endif
let b:did_ftplugin_go = 1

" vim-go  
"" mapping  
""" go runのキーマッピング  
au FileType go nmap gr (go-run)  
""" go testのキーマッピング  
au FileType go nmap gt (go-test)  
"" highlight  
let g:go_hightlight_functions = 1  
let g:go_hightlight_methods = 1  
let g:go_hightlight_structs = 1  
let g:go_hightlight_interfaces = 1  
let g:go_hightlight_operators = 1  
let g:go_hightlight_build_constraints = 1  
"" GoFmt時にインポートするパッケージを整理(GoFmtはファイル書き込み時に自動的に実行される)  
let g:go_fmt_command = "goimports"