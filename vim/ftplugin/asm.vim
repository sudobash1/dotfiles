"disable tab completion for asm files
let b:SuperTabDisabled = 1

setlocal tabstop=8
setlocal shiftwidth=8
setlocal softtabstop=8
setlocal noexpandtab

nnoremap <buffer> <F9> :wa<CR>:call Make()<CR>

" vim: fdm=marker foldlevel=0
