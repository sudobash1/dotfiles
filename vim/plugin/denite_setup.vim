if !exists(":Denite")
  finish
endif

if has("nvim-0.4.0")
  call denite#custom#option("_", 'split', 'floating')
else
  call denite#custom#option("_", 'split', 'horizontal')
endif

"TODO: tune -max-dynamic-update-candidates
call denite#custom#option("_", 'max-dynamic-update-candidates', 3000)

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
     \ "-start-filter " .
     \ "-matchers=matcher/substring,matcher/hide_hidden_files," .
               \ "matcher/ignore_globs,matcher/ignore_current_buffer"
endfunction

nnoremap <silent> <F1> :call <SID>do_denite("file/rec")<CR>
nnoremap <silent> <F3> :call <SID>do_denite("tag")<CR>
if has('nvim')
  " <S-F13> is <F13> in neovim
  nnoremap <silent> <F13> :call <SID>do_denite("buffer")<CR>
  nnoremap <silent> <F15> :<c-u>Denite grep:::! -start-filter -resume -buffer-name="greper"<CR>
endif
nnoremap <leader>f :<c-u>DeniteCursorWord grep <CR>
command! Help Denite help -start-filter


autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  call deoplete#custom#buffer_option('auto_complete', v:false)
  imap <silent><buffer> <C-o>
  \ <Plug>(denite_filter_update)
  inoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  imap <silent><buffer> <Esc>
  \ <Plug>()
  inoremap <silent><buffer><expr> <Esc>
  \ denite#do_map('quit')
  inoremap <silent><buffer><expr> <C-p>
  \ denite#do_map('do_action', 'preview')
  inoremap <silent><buffer><expr> <C-t>
  \ denite#do_map('do_action', 'tabopen')
  inoremap <silent><buffer><expr> <C-v>
  \ denite#do_map('do_action', 'vsplit')
  inoremap <silent><buffer><expr> <C-s>
  \ denite#do_map('do_action', 'split')
  imap <silent><buffer> <Up>
  \ <Plug>(denite_filter_quit)k
  imap <silent><buffer> <Down>
  \ <Plug>(denite_filter_quit)j
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
endfunction

"TODO: split wildignore and add to denite#custom#filter('matcher/ignore_globs'
