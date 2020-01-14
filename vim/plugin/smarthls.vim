"This was inspired by vim-cool: https://github.com/romainl/vim-cool

if !has('nvim')
  finish " nvim only
endif

set hlsearch
nohlsearch

map  <expr> <Plug>smarthls_stop execute('nohlsearch')
map! <expr> <Plug>smarthls_stop execute('nohlsearch')

function! s:disable_hl()
  if v:hlsearch

    " This is used to clear the hlsearch now if we are in CmdlineEnter
    " If this was not here, the nohlsearch would not take effect until after
    " the command line was left. This is a temporary one which will be
    " effective for as long as the cmdline is active
    nohlsearch

    silent call feedkeys("\<Plug>smarthls_stop", 'm')
    redraw
  endif
endfunction

function! s:move_check_hl()
  if v:hlsearch
    " Get the current search's position on this line (if any)
    let l:col = match(getline("."), @/, col(".") - 1) + 1
    " Check to see if it 
    if l:col != col('.')
      silent call feedkeys("\<Plug>smarthls_stop", 'm')
      redraw
    endif
  endif
endfunction

function! s:cmd_leave_check_hl()
  if v:hlsearch
    if v:event['abort']
      silent call feedkeys("\<Plug>smarthls_stop", 'm')
      redraw
    endif
  endif
endfunction

augroup smarthls
  au!
  au InsertEnter,BufLeave,TextChanged,CmdlineEnter * call <SID>disable_hl()
  au CursorMoved * call <SID>move_check_hl()
  au CmdlineLeave [/?] call <SID>cmd_leave_check_hl()
augroup END

nnoremap <ESC> <cmd>nohlsearch<cr>

