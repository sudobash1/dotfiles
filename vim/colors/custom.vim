" Vim color file
"
" To test the theme, run: so $VIMRUNTIME/syntax/hitest.vim
" (see :help hitest)

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

hi Comment    ctermfg=blue   cterm=italic
hi Title      ctermfg=LightMagenta cterm=bold

hi Search ctermbg=178

hi SpellBad ctermbg=none ctermfg=196 cterm=underline,reverse
hi SpellRare ctermbg=none ctermfg=202 cterm=underline,reverse

hi ColorColumn ctermbg=red

hi DiffAdd ctermbg=9
hi DiffText ctermbg=1
hi DiffChange ctermbg=13

hi htmlItalic   cterm=italic
hi mkdItalic    cterm=italic
hi htmlBold     cterm=bold
hi mkdBold      cterm=bold

let colors_name = "custom"

" vim: sw=2
