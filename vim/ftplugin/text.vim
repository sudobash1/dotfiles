setlocal linebreak
if (v:version > 704 || v:version == 704 && has("patch338")) && has("linebreak")
  setlocal breakindent
endif
setlocal cc=0
setlocal nonu
setlocal spell
setlocal textwidth=0
setlocal tabstop=4
noremap <buffer> <up> gk
noremap <buffer> k gk
noremap <buffer> <down> gj
noremap <buffer> j gj
noremap <buffer> ^ g^
noremap <buffer> $ g$
nnoremap <buffer> I g^i
nnoremap <buffer> A g$a

" vim: fdm=marker foldlevel=0
