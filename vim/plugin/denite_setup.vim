if !exists(":Denite")
  finish
endif

if has("nvim-0.4.0")
  call denite#custom#option("_", 'split', 'floating')
else
  call denite#custom#option("_", 'split', 'horizontal')
endif

call denite#custom#filter('matcher/ignore_globs', 'ignore_globs',
      \ ['.hg/', '.git/', '.svn/'] + split(&wildignore, '\s*,\s*'))

"TODO: tune -max-dynamic-update-candidates
"call denite#custom#option("_", "max_dynamic_update_candidates", 20000)
call denite#custom#option("_", "highlight_filter_background", "DeniteFilter")
call denite#custom#option("_", "highlight_matched_char", "DeniteMatch")
call denite#custom#option("_", "highlight_matched_range", "DeniteMatchRange")
call denite#custom#option("_", "start_filter", v:true)
call denite#custom#option("_", 'prompt', '> ')

if executable('ag')
  call denite#custom#var('grep', 'command', ['ag'])
  call denite#custom#var('grep', 'default_opts',
  \ ['--vimgrep', '--nogroup', '--nocolor', '--ignore', 'tags', '--ignore',
  \ 'cscope.out'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', [])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'final_opts', [])
else
  "TODO
endif

call denite#custom#alias('source', 'file/rec/git', 'file/rec')
call denite#custom#var('file/rec/git', 'command',
\ ['git', 'ls-files', '-co', '--exclude-standard'])

function! s:do_denite(source)
  "if a:source ==# "file/rec" && finddir('.git', ';') != ''
  "  let l:source = "file/rec/git"
  "else
  "  let l:source = a:source
  "endif
  exec "Denite " .
     \ a:source . " " .
     \ "-matchers=matcher/hide_hidden_files,matcher/substring," .
               \ "matcher/ignore_globs,matcher/ignore_current_buffer"
endfunction

nnoremap <silent> <F1> :call <SID>do_denite("file/rec")<CR>
nnoremap <silent> <F3> :call <SID>do_denite("tag")<CR>
if has('nvim')
  " <S-F13> is <F13> in neovim
  nnoremap <silent> <F13> :<c-u>call <SID>do_denite("buffer")<CR>
  nnoremap <silent> <F15> :<c-u>Denite grep::-w:! -resume -buffer-name="greper"<CR>
endif
nnoremap <leader>f :<c-u>DeniteCursorWord grep <CR>
command! H Denite help

nnoremap <silent> <bar> :<c-u>Denite line -search<CR>
augroup SbrDeniteAu
  au!
  au FileType c,c++,java,python,bash
        \ nnoremap <silent> <bar>
        \ :<c-u>Denite outline line -search<CR>
augroup END

autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  call deoplete#custom#buffer_option('auto_complete', v:false)
  imap <silent><buffer> <C-o>
  \ <Plug>(denite_filter_update)
  inoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  imap <silent><buffer> <Esc>
  \ <Plug>(denite_filter_update)
  inoremap <silent><buffer><expr> <C-c>
  \ denite#do_map('quit')
  inoremap <silent><buffer><expr> <C-p>
  \ denite#do_map('do_action', 'preview')
  inoremap <silent><buffer><expr> <C-t>
  \ denite#do_map('do_action', 'tabopen')
  inoremap <silent><buffer><expr> <C-v>
  \ denite#do_map('do_action', 'vsplit')
  inoremap <silent><buffer><expr> <C-s>
  \ denite#do_map('do_action', 'split')
  "imap <silent><buffer> <Up>
  "\ <Plug>(denite_filter_quit)k
  "imap <silent><buffer> <Down>
  "\ <Plug>(denite_filter_quit)j
  inoremap <silent><buffer><expr> <F1>
  \ denite#do_map('quit')
  inoremap <silent><buffer><expr> <F3>
  \ denite#do_map('quit')
  if has('nvim')
    inoremap <silent><buffer><expr> <F13>
    \ denite#do_map('quit')
    inoremap <silent><buffer><expr> <F15>
    \ denite#do_map('quit')
  endif
endfunction

autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> <Esc>
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> d
  \ denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <C-o>
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <C-t>
  \ denite#do_map('do_action', 'tabopen')
  nnoremap <silent><buffer><expr> <C-v>
  \ denite#do_map('do_action', 'vsplit')
  nnoremap <silent><buffer><expr> <C-s>
  \ denite#do_map('do_action', 'split')
  nnoremap <silent><buffer><expr> <F1>
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> <F3>
  \ denite#do_map('quit')
  if has('nvim')
    nnoremap <silent><buffer><expr> <F13>
    \ denite#do_map('quit')
    nnoremap <silent><buffer><expr> <F15>
    \ denite#do_map('quit')
  endif
endfunction
