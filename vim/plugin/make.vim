let s:bufname = "[Make Setup]"
let s:bufnr = -1

let s:vars = [
      \ "make_dir",
      \ "make_file",
      \ "make_opts",
      \ "make_pos",
      \ "make_autojump",
      \ "make_autofocus",
\ ]
let s:vars_vals = {
      \ "make_dir": [".", "Directory to perform make in"],
      \ "make_file": ["Makefile", "Name of Makefile"],
      \ "make_opts": ["", "Options to pass to make"],
      \ "make_pos": ["botright", "Position to open quikfix list in"],
      \ "make_autojump": [0, "Automatically jump to first error?"],
      \ "make_autofocus": [1, "Automatically focus quickfix list?"],
\ }

" Set up default values
for var in s:vars
  let g:[var] = get(g:, var, s:vars_vals[var][0])
endfor

function! s:closeMakeSetup()
  let l:lines = getbufline(s:bufname, 1, "$")
  for l:line in l:lines
    execute l:line
  endfor
  execute "bwipeout" s:bufname
  augroup MakeSetup
    au!
  augroup END
endfunction

function! MakeSetup()
  execute len(s:vars) "split"
  noswapfile enew
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal nobuflisted
  setlocal nonumber
  setlocal colorcolumn=0
  setlocal ft=vim
  setlocal completeopt=menu,longest
  execute "file" s:bufname
  augroup MakeSetup
    au!
    au WinLeave <buffer> call s:closeMakeSetup()
    au BufLeave <buffer> call s:closeMakeSetup()
    au BufWinLeave <buffer> call s:closeMakeSetup()
  augroup END
  for l:var in s:vars
    let l:def  = s:vars_vals[l:var][0] " Default value
    let l:desc = s:vars_vals[l:var][1] " Description
    let l:val  = string(get(g:, l:var, l:def))
    call append(line('$'), "let g:".l:var." = ".l:val.' "'.l:desc)
  endfor
  normal ggdd
  nnoremap <buffer> q :bd<CR>
  nnoremap <buffer> Q :bd<CR>
  nnoremap <buffer> <tab>   <esc>/\m^[^=]\+=\s*["']\?\zs<CR>
  nnoremap <buffer> <S-tab> <esc>?\m^[^=]\+=\s*["']\?\zs<CR>
  inoremap <buffer> <tab> <C-X><C-F>
  cnoremap w bd
  cnoremap wq bd
endfunction

function! Make(...)
    let dir = get(a:000, 0, g:make_dir)
    let file = get(a:000, 1, g:make_file)
    let opts = get(a:000, 2, g:make_opts)
    let cmd = g:make_autojump ? "make" : "make!"

    " Use execute normal so that we can append a <CR> so that we don't get
    " the "Press Enter" prompt
    execute "normal! :".cmd." -C ".dir." -f ".file." ".opts."\r"

    execute g:make_pos . " copen"
    if ! g:make_autofocus
      wincmd p
    endif
endfunction

command! MakeSetup call MakeSetup()
command! Make call Make()
