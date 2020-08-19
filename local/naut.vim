command! NautIndentHere setlocal noet ts=4 sw=4 sts=0 cin
command! NautIndentEverywhere set noet ts=4 sw=4 sts=0 cin

augroup naut
  au!
  au BufNewFile,BufEnter /*/repos/nautilus/*.[ch]{,pp} NautIndentHere
augroup END
