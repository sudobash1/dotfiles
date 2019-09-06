"General Notes About Vim: {{{
"
"to convert the current char to ascii use ga
"
" to convert from ^M files to unix files, run :set ff=unix
" to test if something is "set" in vimscript use the ampersand & prefix
" to use a regsiter in vimscript use the at @ prefix
" use <c-u> <c-d> and scroll option for fast navigation
"
" use <c-T> to navigate back from <c-]>
"  Or use <c-W> ] to open in new split
"  Or use <c-W> } to open in the preview window (use :pc to close)
"
" use <c-G> to print full pathname of file (relative to cwd)
"
" use i<character> as a selection command to select inside something.
" ie vi( will select inside parens. a<character> will select around them
",
" To fix the indentation of something, use the = button.
" ie =% reindent entire file == reindent line
"
" To insert character(s) at the same position in a group of lines use I in a
" block select
" ie ^<C-V>jjjjI//<ESC> will comment out five C++ lines.
"
" g; g, will go forward/backward in the changelist
"
" :verbose set option? will tell you where option was last set
"
" In : command mode, <Ctrl-R><Ctrl-W> will insert the current word
"
" "= will prompt you for an expression (1+1 or system('ls') etc...) and will
" allow you to <p>ut the result
" \= will allow you to use the result of a vim command as the replacement text
" in a substitute command (eg  :%s/\d\+/\=printf("0x%04x", submatch(0)) )
"
" <c-r><register> will paste the register in insert mode or command mode
" (this is useful for s/<c-r>//to replace/ because <c-r>/ will show the last
"  searched string)
"  Use " for the unnamed register
"
"  To "dereference" a string into a var, do {"foobar"} or g:{"foobar"}
"
"  To insert a check (✓) type <C-K>OK. To insert an X (✗) type <C-K>XX
"  See :h digraph-table
"
" }}}

"============================= PREINIT ============================= {{{
set nocompatible

let g:vimrc_autoinit = 1
if index(['1', 'yes', 'on', 'true', 'y', 't', 'enable'], tolower($VIM_AUTOINIT)) >= 0
  let g:vimrc_autoinit = 1
elseif index(['0', 'no', 'off', 'false', 'n', 'f', 'disable'], tolower($VIM_AUTOINIT)) >= 0
  let g:vimrc_autoinit = 0
endif

if has('nvim')
  if filereadable(expand($NVIM_PYTHON3))
    let g:python3_host_prog = expand($NVIM_PYTHON3)
  endif
  if filereadable(expand($NVIM_PYTHON))
    let g:python_host_prog = expand($NVIM_PYTHON)
  endif
endif

augroup vimrc
" If this vimrc is being resourced, clear the autocommands so they can be
" defined again without duplicates.
au!
augroup END
" }}}

"============================= VIM PLUG CONFIG ============================= {{{
call plug#begin('~/.vim/bundle')

" have plug install itself
Plug 'junegunn/vim-plug'

Plug 'tpope/vim-repeat' " Helper plugin for vim-surround

Plug 'tpope/vim-surround' " Extra surround keymaps

Plug 'tpope/vim-fugitive' " Intigrate vim with git

Plug 'ntpeters/vim-better-whitespace' "Show trailing whitespace

Plug 'ctrlpvim/ctrlp.vim', {'on': ['CtrlPBuffer','CtrlPTag','CtrlP']} " Fuzzy file finder {{{
let g:ctrlp_map = ''
nnoremap <F1> :call <SID>do_ctrlp()<CR>
let g:ctrlp_by_filename = 1
let g:ctrlp_match_window = 'results:100'

" Find files in all directories that are not hidden or of forbidden extention types
function! s:do_ctrlp()
  if v:count == 2
    CtrlPBuffer
  elseif v:count == 3
    CtrlPTag
  else
    let g:ctrlp_user_command = "find %s -type f -not -path '*/\.*/*'"
    for l:ignore in split(&wildignore, '\s*,\s*')
      let g:ctrlp_user_command .= " -not -path '" . l:ignore . "'"
    endfor
    CtrlP .
  endif
endfunc

" }}}

Plug 'ervandew/supertab' " Tab completion anywhere {{{
let g:SuperTabDefaultCompletionType = "context" " Detect if in a pathname, etc...
let g:SuperTabContextDefaultCompletionType = "<c-x><c-p>" " If above detect fails fallback to cxcp
"let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
"let g:SuperTabDefaultCompletionType = "<C-X><C-O>"

let g:SuperTabClosePreviewOnPopupClose = 1
"Should be the same as
au vimrc CompleteDone * pclose

" Jedi vim should be allowed to autocomplete in cases like "from os import "
" au vimrc FileType python let b:SuperTabNoCompleteAfter = ['^']
" Allow Jedi vim to take precidence
"au vimrc FileType python let b:SuperTabDefaultCompletionType = "<C-X><C-O>"
" Allow Jedi vim to be the fallback if context fails
" au vimrc FileType python call SuperTabSetDefaultCompletionType("<C-X><C-O>")

" }}}

Plug 'milkypostman/vim-togglelist' " Toggle Location list and Quickfix list {{{
let g:toggle_list_no_mappings = 1 "Define mapping(s) myself
"let g:toggle_list_copen_command = "copen 30"
let g:toggle_list_copen_command = "botright copen" "Always fill the lenght of the screen
nnoremap <silent> <F4> :call ToggleQuickfixList()<CR>
"nnoremap <silent> <F5> :call ToggleLocationList()<CR>
" }}}

Plug 'ton/vim-bufsurf' " Allow navigating through buffer history {{{
nnoremap gb :BufSurfBack<CR>
nnoremap gn :BufSurfForward<CR>
" }}}

Plug 'majutsushi/tagbar' "Show an overview of tags for current file {{{

  nnoremap <silent> <F2> :TagbarToggle<CR>

  let g:tagbar_map_togglefold = "<Space>"
  let g:tagbar_map_showproto = "s"
  let g:tagbar_map_togglesort = "t"

  "let g:tagbar_autoclose = 1
  let g:tagbar_previewwin_pos = "" "Use default loc
  let g:tagbar_sort = 0
  let g:tagbar_autofocus = 0
  let g:tagbar_show_visibility = 1
""}}}

Plug 'craigemery/vim-autotag' " Automatically re-generate tag files

Plug 'captbaritone/better-indent-support-for-php-with-html' " Indent PHP + HTML files

Plug 'derekwyatt/vim-fswitch' " Toggle between header and source files {{{
	nnoremap <silent> <Leader>tt :FSHere<cr>
	nnoremap <silent> <Leader>tl :FSRight<cr>
	nnoremap <silent> <Leader>tL :FSSplitRight<cr>
	nnoremap <silent> <Leader>th :FSLeft<cr>
	nnoremap <silent> <Leader>tH :FSSplitLeft<cr>
	nnoremap <silent> <Leader>tk :FSAbove<cr>
	nnoremap <silent> <Leader>tK :FSSplitAbove<cr>
	nnoremap <silent> <Leader>tj :FSBelow<cr>
	nnoremap <silent> <Leader>tJ :FSSplitBelow<cr>
"}}}

Plug 'mattn/emmet-vim' " html editing tools {{{
let g:user_emmet_leader_key='<C-e>'
let g:user_emmet_settings = { 'html' : { 'quote_char' : "'" } }

let g:user_emmet_install_global = 0
au vimrc FileType html,css,php,xml EmmetInstall
"}}}

Plug 'kergoth/vim-bitbake' " Bitbake syntax and file support for vim

if has('cscope')
  Plug 'sudobash1/cscope_dynamic' "{{{
  let g:cscopedb_big_file = "cscope.out"
  let g:cscopedb_small_file = "cache_cscope.out"
  let g:cscopedb_auto_init = g:vimrc_autoinit
  let g:cscopedb_auto_files = 1

  function! s:autodir_cscope()
    let l:dir = getcwd()
    while l:dir != expand("~") && l:dir != "/"
      if filereadable(expand(l:dir . "/" . g:cscopedb_big_file))
        let g:cscopedb_dir = l:dir
      endif
      let l:dir = simplify(expand(l:dir . "/.."))
    endwhile
  endfunc

  if g:cscopedb_auto_init
    call s:autodir_cscope()
  endif

  func! InitCScope()
    call s:autodir_cscope()
    execute "normal \<Plug>CscopeDBInit"
  endfunc
  "}}}
endif

Plug 'davidhalter/jedi-vim' " Context completion for Python {{{
let g:jedi#popup_select_first = 0
let g:jedi#popup_on_dot = 0 "disables the autocomplete to popup whenever you press .
let g:jedi#auto_vim_configuration = 0 " Don't set completeopt

" s:jedigoto {{{
func s:jedigoto()
  echo
  redir => l:goto_output
  silent call jedi#goto_assignments()
  redir END
  if l:goto_output != ""
    try
      tag expand("<cword>")
    catch /E257/
      echohl WarningMsg
      echo "Tag not found"
      echohl None
    endtry
  endif
endfunc
" }}}
au vimrc FileType python nnoremap <buffer> <silent> <C-]> :call <SID>jedigoto()<CR>
au vimrc FileType python nnoremap <buffer> <silent> K :call jedi#show_documentation()<CR>
" }}}

" Async completion [nvim only] (Shougo/deoplete.nvim) {{{
if has('nvim') && has('python3')
  " deoplete requires python3.6.1+ to be installed:
  py3 import sys
  if py3eval("sys.version_info[1] > 6 or (sys.version_info[1] == 6 and sys.version_info[2] > 1)")
    Plug 'Shougo/deoplete.nvim'
    let g:deoplete#enable_at_startup = 1

    " Find list of deoplete plugins at https://github.com/Shougo/deoplete.nvim/wiki/Completion-Sources
    Plug 'Shougo/neco-vim' " deoplete for vimL {{{
    "}}}
    "Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' } " Machine learning autocomplete {{{
    "}}}
    Plug 'deoplete-plugins/deoplete-jedi' " deoplete for python {{{
    "}}}
    Plug 'tweekmonster/deoplete-clang2' " deoplete for C/C++ {{{
    "}}}

    " Experimentally using jedi-vim for parameter display only {{{
      let g:jedi#auto_initialization = 0 " Don't initialize!
      let g:jedi#completions_enabled = 0 " We are using deoplete-jedi for completions
      let g:jedi#auto_vim_configuration = 0 " Don't set completeopt
      let g:jedi#popup_select_first = 0 " Don't auto select first entry
      let g:jedi#popup_on_dot = 0 "disables the autocomplete to popup whenever you press .
    " }}}
  endif
endif
"}}}

" Async linting [nvim only] (dense-analysis/ale) {{{
if has('nvim')
  Plug 'dense-analysis/ale'

  " Use quickfix list instead of location-list
  let g:ale_set_loclist = 0
  let g:ale_set_quickfix = 1
endif
" }}}

Plug 'mrtazz/DoxygenToolkit.vim' "{{{
let g:DoxygenToolkit_authorName="Stephen Robinson"
let g:DoxygenToolkit_briefTag_pre=""
let g:DoxygenToolkit_startCommentTag = "/**"
let g:DoxygenToolkit_startCommentBlock = "/*"
let g:DoxygenToolkit_interCommentTag = "*"
let g:DoxygenToolkit_interCommentBlock = "*"
let g:DoxygenToolkit_briefTag_pre = " @brief "
let g:DoxygenToolkit_paramTag_pre = " @param "
let g:DoxygenToolkit_returnTag = " @return "
let g:DoxygenToolkit_fileTag = " @file "
let g:DoxygenToolkit_authorTag = " @author "
let g:DoxygenToolkit_dateTag = " @date "
let g:DoxygenToolkit_versionTag = " @version "
let g:DoxygenToolkit_blockTag = " @name "
let g:DoxygenToolkit_classTag = " @class "

nnoremap <leader>dl :DoxLic<CR>
nnoremap <leader>da :DoxAuthor<CR>
nnoremap <leader>df :Dox<CR>
nnoremap <leader>dc :Dox<CR>
nnoremap <leader>db :DoxBlock<CR>

syntax region DoxComment start="\/\*\*" end="\*\/" transparent fold
"}}}

Plug 'junkblocker/patchreview-vim' "{{{ Open up patches or git diffs in separate tabs
"Reviewing current changes in your workspace:
":DiffReview
"
"Reviewing staged git changes:
":DiffReview git staged --no-color -U5
"
"Reviewing a patch:
":PatchReview some.patch
"
"Reviewing a previously applied patch (AKA reverse patch review):
":ReversePatchReview some.patch
"
"See :h patchreview for details
"}}}

Plug 'sudobash1/vimwits' " Settings for a project {{{
let g:vimwits_enable = g:vimrc_autoinit
au vimrc Filetype vim,make,sh let b:vimwits_valid_hi_groups = ["", "Identifier"]
"}}}

Plug 'simeji/winresizer' " Resize window mode {{{
let g:winresizer_start_key = '<leader>w'
let g:winresizer_vert_resize = 1
let g:winresizer_horiz_resize = 1
"}}}

Plug 'yssl/QFEnter'  " Open quickfix entry in previous window (and more) {{{
" Be like CtrP
let g:qfenter_keymap = {}
let g:qfenter_keymap.open = ['<CR>', '<2-LeftMouse>']
let g:qfenter_keymap.vopen = ['<C-v>']
let g:qfenter_keymap.hopen = ['<C-CR>', '<C-s>', '<C-x>']
let g:qfenter_keymap.topen = ['<C-t>']
"}}}

Plug 'ekalinin/Dockerfile.vim' "Show trailing whitespace

Plug 'samsaga2/vim-z80' "z80 syntax highlighting

Plug 'godlygeek/tabular' " Allign with the :Tab /<regex> command
" Note: this is required by vim-markdown below

Plug 'plasticboy/vim-markdown' " Render markdown in vim {{{
" ~~Strikethrough~~
let g:vim_markdown_strikethrough = 1
" Allow for following file links without .md extention
let g:vim_markdown_no_extensions_in_markdown = 1
" Use <c-t> and <c-d> to indent or de-indent bullets
"}}}

Plug 'Vimjas/vim-python-pep8-indent' " Force vim to follow pep8



Plug 'guns/xterm-color-table.vim', {'on': 'XtermColorTable'}

"Unused: {{{

"Plugin 'scrooloose/nerdtree' " Browse files from vim {{{
"nnoremap <silent> <F3> :NERDTreeToggle<CR>
"let g:NERDTreeDirArrows = 0 "Turn off NERDTree arrows and use ~ and + instead
"" }}}

"Plugin 'dirkwallenstein/vim-autocomplpop' " automatically open popup window {{{
"Plugin 'eparreno/vim-l9' "Required by autocomplpop
"let g:AutoComplPopDontSelectFirst = 1
"let g:acp_ignorecaseOption = 0 "Don't ignore case
"let g:acp_enableAtStartup = 0 "DISABLE
""}}}

"Plugin 'sudobash1/vprojman.vim' " Settings for a project {{{
"let g:vprojman_autoinit = 0
"let g:vprojman_signature = "-sbr-"
"let g:vprojman_copen_pos = "botright"
"
"let g:run_target = "run"
"nnoremap <F9>  :call vprojman#make()<CR>
"nnoremap <F12> :call vprojman#make(g:run_target)<CR>
"
"command CustCMDpatch call vprojman#patch()
""}}}

"Plugin 'SirVer/ultisnips' "{{{
"Plugin 'honza/vim-snippets' " This repo has a lot of default snippets
"let g:UltiSnipsExpandTrigger="<leader>e"
"let g:UltiSnipsJumpForwardTrigger="<leader><tab>"
"let g:UltiSnipsJumpBackwardTrigger="<leader><s-tab>"
""}}}

"Plugin 'idanarye/vim-vebugger' " Integrate GDB and Vim {{{
"
"Plugin 'Shougo/vimproc.vim' " Required for vim-vebugger. Must be compiled {{{
""}}}
"
"  nnoremap <F10> :VBGstepOver<CR>
"  nnoremap <F11> :VBGstepIn<CR>
"  nnoremap <S-F11> :VBGstepOut<CR>
"  nnoremap <F5> :VBGcontinue<CR>
"
"  nnoremap <S-F5> :VBGstartGDB 
"
"  nnoremap <F9> :VBGtoggleBreakpointThisLine<CR>
"
"  noremap <leader>ve :VBGeval 
"  vnoremap <leader>ve :VBGevalSelectedText<CR>
"
"  noremap <leader>vx :VBGexecute
"  vnoremap <leader>vx :VBGexecuteSelectedText<CR>
"
""}}}

"Plugin 'Valloric/YouCompleteMe' " Code completion for vim {{{
"}}}

"Plugin 'Rip-Rip/clang_complete' " C style langages completion {{{
"let g:clang_snippets = 1
"let g:clang_snippets_engine = 'clang_complete'
"
"autocmd Filetype cpp autocmd InsertLeave * call g:ClangUpdateQuickFix()
"autocmd Filetype cpp autocmd BufWrite * call g:ClangUpdateQuickFix()
"autocmd Filetype c autocmd InsertLeave * call g:ClangUpdateQuickFix()
"autocmd Filetype c autocmd BufWrite * call g:ClangUpdateQuickFix()
"
"let g:clang_user_options='|| exit 0'
"
"let g:clang_close_preview = 1
"let g:clang_complete_macros = 1
"let g:clang_complete_patterns = 1
"
" "I don't want these mappings!
"let g:clang_jumpto_declaration_key = '<C-A-S-F12>'
"let g:clang_jumpto_back_key = '<C-A-S-F12>'
""}}}

"Plugin 'ap/vim-css-color' "Highlight color codes with what they are {{{
"}}}

"Plugin 'ntpeters/vim-better-whitespace' "Highlight trailing whitespace {{{
"}}}

"Plugin 'scrooloose/syntastic' " Syntax checking for vim {{{
"let g:syntastic_error_symbol = 'E>'
"let g:syntastic_warning_symbol = 'W>'
"let g:syntastic_python_checkers = ['pyflakes']
"let g:syntastic_disabled_filetypes=['asm']

" Determine when to refresh the syntax check
"au InsertLeave <buffer> SyntasticCheck
"au InsertEnter <buffer> SyntasticCheck
"au BufWritePost <buffer> SyntasticCheck
"au CursorHold <buffer> SyntasticCheck
"au CursorHoldI <buffer> SyntasticCheck
"au CursorHold <buffer> SyntasticCheck
""au CursorMoved <buffer> SyntasticCheck
"
"noremap <buffer><silent> dd dd:SyntasticCheck<CR>
"noremap <buffer><silent> dw dw:SyntasticCheck<CR>
"noremap <buffer><silent> dW dW:SyntasticCheck<CR>
"noremap <buffer><silent> db db:SyntasticCheck<CR>
"noremap <buffer><silent> dB dB:SyntasticCheck<CR>
"noremap <buffer><silent> de de:SyntasticCheck<CR>
"noremap <buffer><silent> dE dE:SyntasticCheck<CR>
"noremap <buffer><silent> u u:SyntasticCheck<CR>
"noremap <buffer><silent> U U:SyntasticCheck<CR>
"noremap <buffer><silent> p p:SyntasticCheck<CR>
"noremap <buffer><silent> P P:SyntasticCheck<CR>
"noremap <buffer><silent> <C-R> <C-R>:SyntasticCheck<CR>
" }}}

"Plugin 'xolox/vim-misc' "Misc tools for xolox vim plugins {{{
""}}}

"Plugin 'xolox/vim-easytags' "Make ctags better integrated with vim {{{
""}}}

"Plugin 'ap/vim-buftabline' "Show buffers in tabline {{{
"}}}

""}}}

call plug#end()
" }}}

"============================== HACKS CONFIG ============================== {{{

if !has('nvim')
  " Use a bar cursor instead of a block one for insert mode.
  if &term =~ '^xterm' || &term =~ '^tmux'
    " From https://stackoverflow.com/a/42118416
    let &t_SI = "\e[6 q"
    let &t_EI = "\e[2 q"
    autocmd VimEnter * silent !echo -ne "\e[2 q"
  endif
endif

if &term =~ '^screen' || &term =~ '^tmux'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"

    " tmux knows the extended mouse mode
    if has("mouse_sgr")
      set ttymouse=sgr " For columns beyond 223
    else
      set ttymouse=xterm2
    end
endif

au vimrc BufEnter * syntax sync fromstart

"}}}

"============================= GENERAL CONFIG ============================= {{{

filetype plugin indent on

"let mapleader=","

" place backups in ~/.vim/tmp if it exists
set backupdir=~/.local/tmp/vim,.
" Use a unitfied .swp directory for both vim and nvim
set directory=.,~/tmp,/var/tmp,/tmp

" patterns to put to ignore when completing file names
set wildignore=*/*.bak,*/*~,*/*.o,*/*.info,*/*.sw?,*/*.class,*/*.d

"Search for tags file between current down to home directory
set tags=./tags;~

"Disable arrow keys in insert mode, but it will allow the O key to work
"instantly after pressing ESC
"set noesckeys

"Allow O key to work almost instantly while still allowing the arrow keys to
"work
set ttimeoutlen=50

"Allow conceal mode
set conceallevel=2
set concealcursor=inv

set nu
set laststatus=2 "Always show status bar
set encoding=utf-8 "Use utf-8 encoding
set wildchar=<Tab> wildmenu "Tab completion for commands
" Custom tab completion
" 1st tab: longest match
" 2nd tab: provide list of options
" 3rd tab: cycle though options
set wildmode=longest,list,full

set nohlsearch "Do not highlight while seaching
set incsearch "search as soon as characters are entered after /
"set colorcolumn=80 "display soft margin bar.
set scrolloff=5 "keep cursor from reaching bottom of screen
set winminheight=0 "allow 'zipping up' windows
set winminwidth=0 "allow 'zipping up' windows
set hidden "switching buffers will not lose changes/undo history.
set bs=2 "backspace removes tabs
set mouse=a "turn on mouse
set nomousehide "show the mouse in gvim
set noerrorbells visualbell "make no noise
set lazyredraw "Faster redraw
set switchbuf=useopen "How to jump to errors in quickfix
set modeline "You can set vim variables in comments
set tabpagemax=25 "set the maximum number of pages
set foldmethod=indent "set the method of determining where to fold
set foldlevel=99 "Don't fold by default
"set textauto "recognize ^M files
syn on "turn on syntax highlighting

set listchars=eol:$,tab:>-
if (v:version > 704 || v:version == 704 && has("patch710"))
  set listchars+=space:.
endif

"if running in terminal use custom colors.
if !has("gui_running")
  colorscheme custom
endif

"indenting defaults
set shiftwidth=4
set softtabstop=4
"set tabstop=4
set expandtab
set autoindent
set smartindent

"Split settings

"Where new splits will happen.
set splitbelow
set splitright

" }}}

"============================= GREP CONFIG ============================= {{{

if executable('ag')
  " Use ag if we have it
  set grepprg=ag\ --nogroup\ --nocolor\ --vimgrep\ --ignore\ tags\ --ignore\ cscope.out
  set grepformat^=%f:%l:%c:%m   " file:line:column:message
else
  set grepprg=grep\ -n\ -r\ -E
endif

func! s:ag(search_a, search_b)
  let l:args = ""
  if a:search_a != ""
    let l:search=a:search_a
  else
    let l:search=a:search_b
    let l:args .= "-w "
  endif
  if l:search == ""
      echom "ERROR: You must have the cursor on a word or provide an argument"
      return
  endif
  execute "silent! grep! " . l:args . l:search
  botright cwindow
  redraw!
endfunc

command! -nargs=* -complete=file CustCMDag call <SID>ag("<args>", expand("<cword>"))

" }}}

"============================= CSCOPE CONFIG ============================= {{{
if has('cscope')
  set cscopetag cscopeverbose
  set cscoperelative
  set cscopequickfix=s-,c-,d-,i-,t-,e-

"  "csope db autoconnect NON_DYNAMIC {{{
"  function s:autoconnect_cscope()
"    let prefix = "."
"    let orig_cwd = getcwd()
"    while getcwd() != expand("~") && getcwd() != "/"
"      if filereadable("cscope.out")
"        execute "cd " . orig_cwd
"        execute "silent cscope add " . prefix . "/cscope.out "  . prefix
"	return
"      endif
"      cd ..
"      let prefix .= "/.."
"    endwhile
"  endfunc
"  call s:autoconnect_cscope()
"  "}}}

  " s:cscopecmd {{{
  func! s:cscopecmd(cmd, ...)

    let word = ""

    for word in a:000
      if word != ""
        break
      endif
    endfor

    if word == ""
      let error = "ERROR: You must have the cursor on a word"
      if a:cmd != "d"
        let error .= " or provide an argument"
      endif
      echom error
      return
    endif

    if word == "."
      let word = s:curtag()
    endif

    "Determine if this command will use the quickfix list
    let use_quickfix = matchstr(&cscopequickfix, a:cmd . "[+-]") != ""

    "Clear and close the quickfix list if it will be used
    if use_quickfix
      cexpr []
      cclose
      let bufnum = bufnr('%')
    endif

    if a:cmd == "p"
      try
        execute "ptag " . word
      catch /tag not found/
        echom "No matches found for " . word
        return
      endtry
    else
      try
        execute "cscope find " . a:cmd . " " . word
      catch /no matches found for/
        echom "No matches found for " . word
        return
      endtry
    endif

    if len(getqflist()) < 2
      "cexpr []
    elseif use_quickfix
      let tagbar_open = bufwinnr('__Tagbar__') != -1
      if tagbar_open
        let tagbar_autofocus = g:tagbar_autofocus
        let g:tagbar_autofocus = 0
        TagbarToggle
      endif
      execute "buffer " . bufnum
      copen
      wincmd p
      if tagbar_open
        TagbarToggle
        let g:tagbar_autofocus = g:tagbar_autofocus
      endif
    endif
  endfunc
  " }}}

  " s:cscopeGotoIncludeFile {{{
  func! s:cscopeGotoIncludeFile(file)
    if a:file != ""
      let file = a:file
    else
      " Get the file name from the current #include line
      let l = getline('.')
      if matchstr(l, '#include') == ""
        echom "ERROR: this doesn't look like an #include line"
        return
      endif
      let file = substitute(getline('.'), '.*["<]\(.*\)[">].*', '\1', '')
    endif
    call s:cscopecmd("f", file, "")
  endfunc
  " }}}

  func! s:curtag()
    return substitute(tagbar#currenttag('%s',''),"()","","")
  endfunc

  command! -nargs=? CustCMDcs call <SID>cscopecmd("s", "<args>", expand("<cword>"))
  command! -nargs=? CustCMDcg call <SID>cscopecmd("g", "<args>", expand("<cword>"))
  command! CustCMDcd call <SID>cscopecmd("d", s:curtag())
  command! -nargs=? CustCMDcc call <SID>cscopecmd("c", "<args>", expand("<cword>"))
  command! -nargs=? CustCMDcf call <SID>cscopeGotoIncludeFile("<args>")
  command! -nargs=? CustCMDci call <SID>cscopecmd("i", "<args>", fnamemodify(expand('%'), ':t'))
  command! -nargs=? CustCMDct call <SID>cscopecmd("t", "<args>", expand("<cword>"))
  command! -nargs=? CustCMDcp call <SID>cscopecmd("p", "<args>", expand("<cword>"))

endif
" }}}

"================================ COMMANDS ================================ {{{
cnoreabbrev wd w<BAR>bn<BAR>bd #

"Save with root permissions
"cnoremap w!! w !sudo tee % >/dev/null
cnoreabbrev  w!! w !sudo tee % >/dev/null

command! BD bp<BAR>bd #

" }}}

"============================= KEY MAPPINGS ============================= {{{

" I never use ex mode
nnoremap Q <Nop>

"Press space to toggle current fold
nnoremap <space> za

"Press F1 to start selecting a buffer to switch too.
"nnoremap <F1> :buffer

"Doublepress the leader to get a prompt to do one of my custom commands
nnoremap <leader><leader> :CustCMD

nnoremap <leader>h :echo printf("0x%x", expand('<cword>'))<CR>

"System clipboard
nnoremap <C-P> "+p
nnoremap <C-Y> "+y
inoremap <C-P> <ESC>"+pi
inoremap <C-Y> <ESC>"+yi
vnoremap <C-Y> <ESC>"+yi
vnoremap <C-P> "+p

"Word by word navigation
inoremap <C-right> <esc>lwi
inoremap <C-left> <esc>bi

"Error window
nnoremap <F10> :silent cprevious<CR>
nnoremap <F11> :silent cnext<CR>

"Resize windows
nnoremap + <C-W>+
nnoremap - <C-W>-

"Select last pasted text
nnoremap gp `[v`]

" }}}

"============================= CUSTOM HIGHLIGHTS ============================= {{{

hi GoodText ctermfg=lightgreen cterm=bold
au vimrc filetype markdown call matchadd("GoodText", "✓")

hi BadText ctermfg=red cterm=bold
au vimrc filetype markdown call matchadd("BadText", "✗")

hi StarText ctermfg=yellow cterm=bold
au vimrc filetype markdown call matchadd("StarText", "★")

" }}}

"============================ FILETYPE CONFIG ============================ {{{

"Change c indentation rules to match my style:
set cinoptions+=(4m1 "This makes only one indentation happen after (

set cinoptions+=g0 "disable for access modifiers

" commit messages {{{
au vimrc Filetype svn,*commit* setlocal spell
" }}}

" Java {{{
"au vimrc Filetype java set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
"au vimrc Filetype java inoremap {<CR> {<CR>}<C-O>O
"au vimrc Filetype java inoremap {{ <CR>{<CR>}<C-O>O
"au vimrc Filetype java inoremap { {}<Left>
"au vimrc Filetype java inoremap {<ESC> <C-O>a
"au vimrc Filetype java inoremap {[ {

" }}}

" C/C++ {{{
au vimrc Filetype c,cpp set foldmethod=syntax
" }}}

" SML {{{
" no autowrap XXX Why can't I put the t and c on one line?
au vimrc FileType sml setlocal formatoptions-=t
au vimrc FileType sml setlocal formatoptions-=c
au vimrc FileType sml setlocal shiftwidth=2
au vimrc FileType sml setlocal softtabstop=2
" }}}

" JSON {{{
au vimrc FileType json setlocal conceallevel=0
" }}}

" Text {{{
au vimrc FileType text,markdown setlocal linebreak
if (v:version > 704 || v:version == 704 && has("patch338")) && has("linebreak")
  au vimrc FileType text,markdown setlocal breakindent
endif
au vimrc FileType text,markdown setlocal cc=0
au vimrc FileType text,markdown setlocal nonu
au vimrc FileType text,markdown setlocal spell
au vimrc FileType help setlocal nospell
au vimrc FileType text,markdown setlocal textwidth=0
au vimrc FileType text,markdown setlocal tabstop=4
au vimrc FileType text,markdown noremap <buffer> <up> gk
au vimrc FileType text,markdown noremap <buffer> k gk
au vimrc FileType text,markdown noremap <buffer> <down> gj
au vimrc FileType text,markdown noremap <buffer> j gj
au vimrc FileType text,markdown noremap <buffer> ^ g^
au vimrc FileType text,markdown noremap <buffer> $ g$
au vimrc FileType text,markdown nnoremap <buffer> I g^i
au vimrc FileType text,markdown nnoremap <buffer> A g$a
" Never conseal MD characters on the current (or visually selected) line
au vimrc FileType markdown setlocal concealcursor=

" }}}

" Assembly {{{

"disable tab completion for asm files
silent au vimrc FileType asm,z80 let b:SuperTabDisabled = 1

au vimrc FileType asm,z80 setlocal tabstop=8
au vimrc FileType asm,z80 setlocal shiftwidth=8
au vimrc FileType asm,z80 setlocal softtabstop=8
au vimrc FileType asm,z80 setlocal noexpandtab
" }}}

" Vim {{{
au vimrc FileType vim nnoremap <buffer> K :execute "help " . expand('<cword>')<CR>
au vimrc FileType vim vnoremap <buffer> K "ty:help <C-R>t<CR>
" }}}

" Tmux {{{
au vimrc  FileType tmux nnoremap <F9> :wa<bar>:!tmux source ~/.tmux.conf<CR>
" }}}

" Special Indentation Rules {{{

au vimrc FileType html setlocal shiftwidth=2
au vimrc FileType php setlocal shiftwidth=2
au vimrc FileType css setlocal shiftwidth=2
au vimrc FileType vim setlocal shiftwidth=2
au vimrc FileType sh setlocal shiftwidth=2

au vimrc FileType make setlocal tabstop=8
au vimrc FileType make setlocal noexpandtab

set softtabstop=-1 " use shiftwidth

" }}}

au vimrc Filetype java,asm,c,cpp,make nnoremap <F9> :wa<CR>:call Make()<CR>

" }}}

"============================== MINI SCRIPTS ============================= {{{

" ToDo Lister {{{
" List all the TODO & XXX & FIXME & DEBUG comments
  function! ToDoLister()
    let l:ext=&filetype
    if l:ext == 'c' || l:ext == 'cpp' || l:ext == 'cc' || l:ext == "h" || l:ext == "hpp"
      noautocmd vimgrep /TODO\|XXX\|FIXME\|DEBUG/j **/*.h **/*.c **/*.cpp **/*.hpp **/*.cc
    else
      exe "noautocmd vimgrep /TODO\\\|XXX\\\|FIXME\\\|DEBUG/j **/*." . l:ext
    endif
    cw
  endfunction

  "nnoremap <f5> :call ToDoLister()<CR>
" }}}

" Return to previous position when reopening file {{{
au vimrc BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" }}}

" Make line {{{
" Make a line of the specified character to the colorcolumn
function! MakeLine(char)
  let l:dist=&colorcolumn
  if l:dist == 0
    let l:dist = 80
  endif
  while getpos('.')[2] < (l:dist - 1)
    exe "normal! A" . a:char . "\<esc>"
  endwhile
endfunction

nnoremap <leader>l :call MakeLine('')<left><left>
" }}}

"" DISABLED: Always spell correct {{{
"" Always allow spelling correction, even when not 'set spell'
"function! s:SpellCorrect()
"  if &spell
"    normal! z=
"  else
"    set spell
"    normal! z=
"    set nospell
"  endif
"endfunction
"
"nnoremap z= :call <SID>SpellCorrect()<CR>
" }}}

" Generate gdb break for current line {{{
function! GenerateBreakpoint()
  " TODO: what about paths with spaces?
  let l:cmd = "break " . expand('%:p') . ":" . line('.')
  let l:buf = shellescape(l:cmd)
  exec 'silent ! [ "$TMUX" ] && tmux set-buffer ' . l:buf
  redraw!
  echo l:cmd
endfunction
au vimrc Filetype c nnoremap <buffer> <leader>b :call GenerateBreakpoint()<CR>
au vimrc Filetype cpp nnoremap <buffer> <leader>b :call GenerateBreakpoint()<CR>
" }}}

"The directory the MAKEFILE is in.
let g:make_dir = "."
let g:make_file = "Makefile"
let g:make_opts = ""
let g:make_pos = "botright"
let g:make_autojump = 0
let g:make_autofocus = 1

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

function! MakeSetup()
  try

    call inputsave()
    let wildmode = &wildmode
    let &wildmode = "list:longest"

    redraw
    let g:make_dir = input("g:make_dir = ", g:make_dir, "dir")

    try
      " Get into the make_dir to be able to file name complete the makefile
      let orig_dir = getcwd()
      silent! cd -
      let old_dir = getcwd()
      silent! execute "cd!" g:make_dir

      redraw
      let g:make_file = input("g:make_file = ", g:make_file, "file")
    finally
      " Get back into the other dir
      silent! execute "cd " old_dir
      silent! execute "cd!" orig_dir
    endtry

    for var in ["opts", "pos", "autojump", "autofocus"]
      redraw
      execute "let g:make_".var." = input('g:make_".var." = ','".g:{"make_".var}."')"
    endfor

  finally
    call inputrestore()
    let &wildmode = wildmode
  endtry
endfunction

function! GnuIndent()
  setlocal cindent
  setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal textwidth=79
  setlocal fo-=ro fo+=cql
endfunction

" }}}

"============================== STATUS/TAB LINE ============================= {{{
set statusline=%t\     "tail of the filename

"set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
"set statusline+=%{&ff}] "file format

set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag

"set statusline+=%y      "filetype

set statusline+=%{tagbar#currenttag('\ \ <%s>','')}

let g:statusline_cscope_update_status = ""
set statusline+=%{g:statusline_cscope_update_status}

set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file

function! Cscope_dynamic_update_hook(updating)
  if a:updating
    let g:statusline_cscope_update_status = "  (Updating cscope...)"
  else
    let g:statusline_cscope_update_status = ""
  endif
  execute "redrawstatus!"
endfunction

"modified from https://github.com/mkitt/tabline.vim/blob/master/plugin/tabline.vim
function! s:tabline()
  let prelen = 0    " Length of tab labels before the active one
  let activelen = 0 " Length of active tab label
  let postlen = 0   " Length of tab labels after the active one
  let postarrow = 0 " Use a > at end

  let prestrs = []   " Tab labels before the active one
  let activestr = "" " Active tab label
  let poststrs = []  " Tab labels after the active one

  for i in range(tabpagenr('$'))
    let tab = i + 1
    let winnr = tabpagewinnr(tab)
    let buflist = tabpagebuflist(tab)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    let tabname = gettabvar(tab, "tab_name", bufname)
    let bufmodified = getbufvar(bufnr, "&mod")
    let active = (tab == tabpagenr())

    let s = ' ' . tab .':['
    let s .= (tabname != '' ? fnamemodify(tabname, ':t') : 'No Name')
    let s .= '] '

    " Only add modified flag if the tab name is the same as the buffer name
    if bufmodified && tabname == bufname
      let s .= '[+] '
    endif

    if active
      let activelen = strlen(s)
      let activestr = s
    elseif activestr == ""
      let prelen += strlen(s)
      call add(prestrs, s)
    else
      let postlen += strlen(s)
      call add(poststrs, s)
    endif

  endfor

  let screen_width=&columns-2

  let activei = (len(prestrs)+1)
  let s = '%' . activei . 'T%#TabLineSel#' . activestr
  let total_len = activelen
  let prearrow = 0
  let postarrow = 0
  let i = 0
  while len(prestrs) + len(poststrs)
    let i += 1
    let pre = (len(prestrs) ? remove(prestrs, -1) : "" )
    let post = (len(poststrs) ? remove(poststrs, 0) : "" )
    let arrow_len = (len(prestrs) != 0) + (len(poststrs) != 0)
    let new_len = total_len + strlen(pre) + strlen(post)
    if new_len > screen_width
      " We have too many things on the screen. We need to start trimming off
      " characters from tabs
      while new_len > screen_width && (strlen(pre) || strlen(post))
        if strlen(post)
          let post = post[0:-2]
          let new_len -= 1
          let postarrow = 1
        endif
        if new_len > screen_width && strlen(pre)
          let pre = pre[1:-1]
          let new_len -= 1
          let prearrow = 1
        endif
      endwhile
    endif

    if strlen(pre)
      let s = '%' . (activei - i) . 'T%#TabLine#' . pre . s
    endif
    if strlen(post)
      let s .= '%' . (activei + i) . 'T%#TabLine#' . post
    endif
    let total_len += strlen(pre) + strlen(post)

    if new_len >= screen_width
      " If we include the arrows, we have used up 100% of the screen_width
      " Stop here!
      break
    endif
  endwhile

  let s .= '%#TabLine#' " In case the last tab is active

  if len(prestrs) || prearrow
    let s = '<' . s
  endif
  if len(poststrs) || postarrow
    let s .= '%=>'
  endif

  return s
endfunction
set tabline=%!<sid>tabline()

command! -nargs=? Tabname if "<args>" != "" | let t:tab_name="<args>" | else | unlet t:tab_name | endif | redraw!

" }}}

if filereadable(expand("~") . "/.vimrc.local.vim")
  source ~/.vimrc.local.vim
endif

" vim: fdm=marker foldlevel=0
