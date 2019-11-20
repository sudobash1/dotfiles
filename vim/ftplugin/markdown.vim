runtime! ftplugin/text.vim ftplugin/text_*.vim ftplugin/text/*.vim

au vimrc FileType markdown setlocal concealcursor=


"============================= CUSTOM HIGHLIGHTS ============================= {{{
hi GoodText ctermfg=lightgreen cterm=bold
hi BadText ctermfg=red cterm=bold
hi StarText ctermfg=yellow cterm=bold

call matchadd("GoodText", "✓")
call matchadd("BadText", "✗")
call matchadd("StarText", "★")
" }}}

" vim: fdm=marker foldlevel=0
