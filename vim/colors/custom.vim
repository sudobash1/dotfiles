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

hi Comment          ctermfg=12  cterm=italic
hi Constant         ctermfg=13
hi Identifier       ctermfg=14  cterm=bold
hi PreProc          ctermfg=115
hi Type             ctermfg=10
hi Special          ctermfg=182
hi Statement        ctermfg=11

hi Title            ctermfg=13  cterm=bold

hi ColorColumn      ctermbg=1
hi Search           ctermbg=178
hi Folded           ctermfg=4   ctermbg=249

hi SpellBad         ctermbg=196 ctermfg=0 cterm=underline
hi SpellRare        ctermbg=202 ctermfg=0 cterm=underline

hi DiffAdd          ctermbg=52
hi DiffText         ctermbg=88  cterm=bold
hi DiffChange       ctermbg=237

hi htmlItalic       cterm=italic
hi mkdItalic        cterm=italic
hi htmlBold         cterm=bold
hi mkdBold          cterm=bold
hi mkdCode          ctermfg=12 ctermbg=8
hi mkdCodeDelimiter ctermfg=4

let colors_name = "custom"

" vim: sw=5
