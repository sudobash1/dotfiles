" Vim color file

" This is the default color scheme.  It doesn't define the Normal
" highlighting, it uses whatever the colors used to be.

" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif


hi Comment    ctermfg=darkblue   cterm=bold
"hi String     ctermfg=brown   cterm=bold
"hi Number     ctermfg=brown   cterm=bold
"hi ColorColumn ctermfg=green

hi DiffAdd ctermbg=9
hi DiffText ctermbg=1
hi DiffChange ctermbg=13

let colors_name = "custom"

" vim: sw=2
