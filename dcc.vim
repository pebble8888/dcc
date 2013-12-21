"
" DoxygenCommentCreator vim plugin
" pebble8888/dcc.vim
" pebble8888@gmail.com
"

function! DoxygenCommentCreator()
  let s:linenum = line(".")
  let s:cmd = "dcc.rb " . bufname("%") . " " . s:linenum
  let s:buf = system(s:cmd)
  call append(s:linenum-1, split(s:buf, '\n'))
endfunction

if !exists('g:dcc_no_default_key_mappings')
  noremap ,d :call DoxygenCommentCreator()<CR>
endif
