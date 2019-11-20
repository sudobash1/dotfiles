setlocal shiftwidth=2

nnoremap <buffer> K :execute "help " . expand('<cword>')<CR>
vnoremap <buffer> K "ty:help <C-R>t<CR>

nnoremap <buffer> <F9> :wa<CR>:call Make()<CR>

" vim: fdm=marker foldlevel=0
