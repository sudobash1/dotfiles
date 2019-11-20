setlocal foldmethod=syntax

nnoremap <buffer> <F9> :wa<CR>:call Make()<CR>

" Generate gdb break for current line {{{
function! GenerateBreakpoint()
  " TODO: what about paths with spaces?
  let l:cmd = "break " . expand('%:p') . ":" . line('.')
  let l:buf = shellescape(l:cmd)
  exec 'silent ! [ "$TMUX" ] && tmux set-buffer ' . l:buf
  redraw!
  echo l:cmd
endfunction
nnoremap <buffer> <leader>b :call GenerateBreakpoint()<CR>
" }}}

" Set C indentation settings to the Gnu standard {{{
function! GnuIndent()
  setlocal cindent
  setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal textwidth=79
  setlocal fo-=ro fo+=cql
endfunction
command! GnuIndent :call GnuIndent()<CR>
" }}}

" vim: fdm=marker foldlevel=0
