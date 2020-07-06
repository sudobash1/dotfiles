setlocal conceallevel=0
let g:tex_indent_items=0

" TODO: Possibly replace this code with rubber and Make:
" https://vim.fandom.com/wiki/Compiling_LaTeX_from_Vim
let s:settings = {
      \ 'flavor': 'lualatex',
      \ 'args': '',
      \ }
for s:line in getline(0, '$')
  let s:match = matchlist(s:line, '%\s*tex-\([a-z-]\+\):\s*\(.*\)')
  if !empty(s:match)
    let s:settings[s:match[1]] = s:match[2]
  endif
endfor
execute
      \ 'setlocal makeprg='
      \ . s:settings['flavor']
      \ . '\ \-file\-line\-error\ \-interaction=nonstopmode\ '
      \ . s:settings['args']
setlocal errorformat=%f:%l:\ %m,%oWarning:\ %m

function! s:preview() abort
  let l:pdf = expand('%:p:r') . '.pdf'
  if executable('evince')
    silent execute '!evince ' . l:pdf . ' &'
  endif
endfunction

noremap <F9> :w<CR>:make %<CR><CR><C-L>
nmap <F12> <F9>:call <SID>preview()<CR><CR>
