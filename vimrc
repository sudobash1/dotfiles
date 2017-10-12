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
"
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
" }}}

let g:vimrc_autoinit = 1
if index(['1', 'yes', 'on', 'true', 'y', 't', 'enable'], tolower($VIM_AUTOINIT)) >= 0
  let g:vimrc_autoinit = 1
elseif index(['0', 'no', 'off', 'false', 'n', 'f', 'disable'], tolower($VIM_AUTOINIT)) >= 0
  let g:vimrc_autoinit = 0
endif

set nocompatible " be iMproved, required

"============================= VUNDLE CONFIG ============================= {{{
filetype off "required for now to use vundle

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
"alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'tpope/vim-fugitive.git' " Intigrate vim with git {{{
"}}}

Plugin 'ntpeters/vim-better-whitespace' "Show trailing whitespace {{{
"}}}

Plugin 'kien/ctrlp.vim' " Fuzzy file finder {{{
let g:ctrlp_map = '<F1>'
let g:ctrlp_cmd = 'call VIMRC_do_ctrlp()'
let g:ctrlp_by_filename = 1
let g:ctrlp_match_window = 'results:100'

" Find files in all directories that are not hidden or of forbidden extention types
function VIMRC_do_ctrlp()
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

Plugin 'ervandew/supertab' " Tab completion anywhere {{{
"let g:SuperTabDefaultCompletionType = "context" " Detect if in a pathname, etc...
let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
"let g:SuperTabDefaultCompletionType = "<C-X><C-O>"

let g:SuperTabClosePreviewOnPopupClose = 1
"Should be the same as
autocmd CompleteDone * pclose

" }}}

Plugin 'scrooloose/nerdtree' " Browse files from vim {{{
nnoremap <silent> <F3> :NERDTreeToggle<CR>
let g:NERDTreeDirArrows = 0 "Turn off NERDTree arrows and use ~ and + instead
" }}}

Plugin 'milkypostman/vim-togglelist' " Toggle Location list and Quickfix list {{{
let g:toggle_list_no_mappings = 1 "Define mapping(s) myself
"let g:toggle_list_copen_command = "copen 30"
let g:toggle_list_copen_command = "botright copen" "Always fill the lenght of the screen
nnoremap <silent> <F4> :call ToggleQuickfixList()<CR>
"nnoremap <silent> <F5> :call ToggleLocationList()<CR>
" }}}

Plugin 'ton/vim-bufsurf' " Allow navigating through buffer history {{{
nnoremap gb :BufSurfBack<CR>
nnoremap gn :BufSurfForward<CR>
" }}}

Plugin 'majutsushi/tagbar' "Show an overview of tags for current file {{{

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

Plugin 'craigemery/vim-autotag' " Automatically re-generate tag files {{{
" }}}

Plugin 'captbaritone/better-indent-support-for-php-with-html' " Indent PHP + HTML files {{{
"}}}

Plugin 'derekwyatt/vim-fswitch' " Toggle between header and source files {{{
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

Plugin 'mattn/emmet-vim' " html editing tools {{{
let g:user_emmet_leader_key='<C-y>'
let g:user_emmet_settings = { 'html' : { 'quote_char' : "'" } }

let g:user_emmet_install_global = 0
autocmd FileType html,css,php,xml EmmetInstall
"}}}

if has('cscope')
  Plugin 'sudobash1/cscope_dynamic' "{{{
  let g:cscopedb_big_file = "cscope.out"
  let g:cscopedb_small_file = "cache_cscope.out"
  let g:cscopedb_auto_init = g:vimrc_autoinit
  let g:cscopedb_auto_files = 1

  function s:autodir_cscope()
    let l:dir = getcwd()
    while l:dir != expand("~") && getcwd() != "/"
      if filereadable(expand(l:dir . "/" . g:cscopedb_big_file))
        let g:cscopedb_dir = l:dir
      endif
      let l:dir = simplify(expand(l:dir . "/.."))
    endwhile
  endfunc

  if g:cscopedb_auto_init
    call s:autodir_cscope()
  endif

  func InitCScope()
    call s:autodir_cscope()
    execute "normal \<Plug>CscopeDBInit"
  endfunc
  "}}}
endif

Plugin 'mrtazz/DoxygenToolkit.vim' "{{{
let g:DoxygenToolkit_authorName="Stephen Robinson"
let g:DoxygenToolkit_briefTag_pre=""

nnoremap <leader>dl :DoxLic<CR>
nnoremap <leader>da :DoxAuthor<CR>
nnoremap <leader>df :Dox<CR>
nnoremap <leader>dc :Dox<CR>
nnoremap <leader>db :DoxBlock<CR>

syntax region DoxComment start="\/\*\*" end="\*\/" transparent fold
"}}}

Plugin 'junkblocker/patchreview-vim' "{{{ Open up patches or git diffs in separate tabs
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

Plugin 'sudobash1/vimwits' " Settings for a project {{{
let g:vimwits_enable = g:vimrc_autoinit
autocmd Filetype vim,make,sh let b:vimwits_valid_hi_groups = ["", "Identifier"]
"}}}

Plugin 'simeji/winresizer' " Resize window mode {{{
let g:winresizer_start_key = '<leader>w'
let g:winresizer_vert_resize = 1
let g:winresizer_horiz_resize = 1
"}}}

Plugin 'yssl/QFEnter'  " Open quickfix entry in prev window (and more) {{{
" Be like CtrP
let g:qfenter_keymap = {}
let g:qfenter_keymap.open = ['<CR>', '<2-LeftMouse>']
let g:qfenter_keymap.vopen = ['<C-v>']
let g:qfenter_keymap.hopen = ['<C-CR>', '<C-s>', '<C-x>']
let g:qfenter_keymap.topen = ['<C-t>']
"}}}

"Unused: {{{

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

"Plugin 'davidhalter/jedi-vim' " Context completion for Python {{{
"let g:jedi#popup_on_dot = 0 "disables the autocomplete to popup whenever you press .
" }}}

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

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" }}}

"============================== HACKS CONFIG ============================== {{{

if &term =~ '^screen'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"

    " tmux know the extended mouse mode
    set ttymouse=xterm2
endif

"}}}

"============================= GENERAL CONFIG ============================= {{{

"let mapleader=","

" place backups in ~/.vim/tmp if it exists
set backupdir=~/.local/tmp/vim,.

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
set wildchar=<Tab> wildmenu wildmode=full "Tab completion for commands
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

"if running in terminal use custom colors.
if !has("gui_running")
  set t_Co=8
  if has ('nvim')
    autocmd VimEnter * colorscheme custom
  else
    colorscheme custom
  endif
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
  func s:cscopecmd(cmd, ...)

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
  func s:cscopeGotoIncludeFile(file)
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

  func s:curtag()
    return substitute(tagbar#currenttag('%s',''),"()","","")
  endfunc

  command -nargs=? CustCMDcs call <SID>cscopecmd("s", "<args>", expand("<cword>"))
  command -nargs=? CustCMDcg call <SID>cscopecmd("g", "<args>", expand("<cword>"))
  command CustCMDcd call <SID>cscopecmd("d", s:curtag())
  command -nargs=? CustCMDcc call <SID>cscopecmd("c", "<args>", expand("<cword>"))
  command -nargs=? CustCMDcf call <SID>cscopeGotoIncludeFile("<args>")
  command -nargs=? CustCMDci call <SID>cscopecmd("i", "<args>", fnamemodify(expand('%'), ':t'))
  command -nargs=? CustCMDct call <SID>cscopecmd("t", "<args>", expand("<cword>"))
  command -nargs=? CustCMDcp call <SID>cscopecmd("p", "<args>", expand("<cword>"))

endif
" }}}

"================================ COMMANDS ================================ {{{
cnoreabbrev wd w<BAR>bd

"Save with root permissions
"cnoremap w!! w !sudo tee % >/dev/null
cnoreabbrev  w!! w !sudo tee % >/dev/null

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

"Move current/selected lines up/down
"nnoremap <C-Up> "zddkk$p
"nnoremap <C-Down> "zdd$p
"vnoremap <C-Up> "zxkk$p
"vnoremap <C-Down> "zx$p

"in buffer movement
nnoremap gj <PageDown>
nnoremap gk <PageUp>
nnoremap gh <Home>
nnoremap gl <End>
vnoremap gj <PageDown>
vnoremap gk <PageUp>
vnoremap gh <Home>
vnoremap gl <End>

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

"============================ FILETYPE CONFIG ============================ {{{

"Change c indentation rules to match my style:
set cinoptions+=(4m1 "This makes only one indentation happen after (

set cinoptions+=g0 "disable for access modifiers

" commit messages {{{
autocmd Filetype svn,*commit* setlocal spell
" }}}

" Java {{{
"autocmd Filetype java set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
"autocmd Filetype java inoremap {<CR> {<CR>}<C-O>O
"autocmd Filetype java inoremap {{ <CR>{<CR>}<C-O>O
"autocmd Filetype java inoremap { {}<Left>
"autocmd Filetype java inoremap {<ESC> <C-O>a
"autocmd Filetype java inoremap {[ {

" }}}

" C++ {{{
"autocmd Filetype cpp set errorformat=%f:%l:%c:%m,%f:kk%l:\ %m,In\ file\ included\ from\ %f:%l:,\^I\^Ifrom\ %f:%l%m,\"%f\"\\\,\ line\ %l.%c:%m\,\ %f:%l:%m,%f:%l:%c:%m
"autocmd Filetype cpp set errorformat^=%-GIn\ file\ included\ %.%# 
"autocmd Filetype cpp set errorformat^=%-Gavrdude%.%#
autocmd Filetype cpp set foldmethod=syntax
" }}}

" C {{{
"autocmd Filetype c set errorformat=%f:%l:%c:%m,%f:kk%l:\ %m,In\ file\ included\ from\ %f:%l:,\^I\^Ifrom\ %f:%l%m,\"%f\"\\\,\ line\ %l.%c:%m\,\ %f:%l:%m,%f:%l:%c:%m
"autocmd Filetype c set errorformat^=%-GIn\ file\ included\ %.%# 
"autocmd Filetype c set errorformat^=%-Gavrdude%.%#
" }}}

" SML {{{
" no autowrap XXX Why can't I put the t and c on one line?
autocmd FileType sml setlocal formatoptions-=t
autocmd FileType sml setlocal formatoptions-=c
autocmd FileType sml setlocal shiftwidth=2
autocmd FileType sml setlocal softtabstop=2
" }}}

" Text {{{
autocmd FileType text setlocal linebreak
autocmd FileType text setlocal cc=0
autocmd FileType text setlocal nonu
autocmd FileType text setlocal spell
autocmd FileType help setlocal nospell
autocmd FileType text setlocal textwidth=0
autocmd FileType text setlocal tabstop=4
autocmd FileType text setlocal noexpandtab
autocmd FileType text noremap <buffer> <up> gk
autocmd FileType text noremap <buffer> k gk
autocmd FileType text noremap <buffer> <down> gj
autocmd FileType text noremap <buffer> j gj
autocmd FileType text noremap <buffer> ^ g^
autocmd FileType text noremap <buffer> $ g$
autocmd FileType text nnoremap <buffer> I g^i
autocmd FileType text nnoremap <buffer> A g$a
" }}}

" Assembly {{{

"disable tab completion for asm files
silent autocmd FileType asm let b:SuperTabDisabled = 1

autocmd FileType asm setlocal tabstop=8
autocmd FileType asm setlocal shiftwidth=8
autocmd FileType asm setlocal softtabstop=8
autocmd FileType asm setlocal noexpandtab
" }}}

" Vim {{{
autocmd FileType vim nnoremap <buffer> K :execute "help " . expand('<cword>')<CR>
autocmd FileType vim vnoremap <buffer> K "ty:help <C-R>t<CR>
" }}}

" Special Indentation Rules {{{

autocmd FileType html setlocal shiftwidth=2
autocmd FileType php setlocal shiftwidth=2
autocmd FileType css setlocal shiftwidth=2
autocmd FileType vim setlocal shiftwidth=2
autocmd FileType sh setlocal shiftwidth=2

autocmd FileType make setlocal tabstop=8
autocmd FileType make setlocal noexpandtab

set softtabstop=-1 " use shiftwidth

" }}}

autocmd Filetype java,asm,c,cpp,make nnoremap <F9> :wa<CR>:call Make()<CR>

" }}}

"============================== MINI SCRIPTS ============================= {{{

" ToDo Lister {{{
" List all the TODO & XXX & FIXME & DEBUG comments
  function ToDoLister()
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
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
" }}}

" Make line {{{
" Make a line of the specified character to the colorcolumn
function MakeLine(char)
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
"function s:SpellCorrect()
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
function GenerateBreakpoint()
  " TODO: what about paths with spaces?
  let l:cmd = "break " . expand('%:p') . ":" . line('.')
  let l:buf = shellescape(l:cmd)
  exec 'silent ! [ "$TMUX" ] && tmux set-buffer ' . l:buf
  redraw!
  echo l:cmd
endfunction
autocmd Filetype c nnoremap <buffer> <leader>b :call GenerateBreakpoint()<CR>
autocmd Filetype c++ nnoremap <buffer> <leader>b :call GenerateBreakpoint()<CR>
" }}}

"The directory the MAKEFILE is in.
let g:make_dir = "."
let g:make_file = "Makefile"
let g:make_opts = ""
let g:make_pos = "botright"
let g:make_autojump = 0
let g:make_autofocus = 1

function Make(...)
    let dir = get(a:000, 0, g:make_dir)
    let file = get(a:000, 1, g:make_file)
    let ops = get(a:000, 2, g:make_opts)
    let cmd = g:make_autojump ? "make" : "make!"

    " Use execute normal so that we can append a <CR> so that we don't get
    " the "Press Enter" prompt
    execute "normal! :".cmd." -C ".dir." -f ".file." ".g:make_opts."\r"

    execute g:make_pos . " copen"
    if ! g:make_autofocus
      wincmd p
    endif
endfunction

function MakeSetup()
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

function! g:Cscope_dynamic_update_hook(updating)
  if a:updating
    let g:statusline_cscope_update_status = "  (Updating cscope...)"
  else
    let g:statusline_cscope_update_status = ""
  endif
  execute "redrawstatus!"
endfunction

"modified from https://github.com/mkitt/tabline.vim/blob/master/plugin/tabline.vim
function! VIMRC_Tabline()
  let prelen = 0    " Length of tab labels before the active one
  let activelen = 0 " Length of active tab label
  let postlen = 0   " Length fo tab labels after the active one
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
    let active = tab == tabpagenr()

    let s = ' ' . tab .':'
    let s .= (tabname != '' ? '['. fnamemodify(tabname, ':t') . '] ' : '[No Name] ')

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

  while prelen + activelen + postlen + postarrow > &columns
    if postlen > 0
      let trimed = remove(poststrs, -1)
      let postlen -= strlen(trimed)
      let postarrow = 1
    else
      "We can't even display the entire active tab :(
      let postarrow = 1
      break
    endif
  endwhile

  let total_len = prelen + activelen + postlen + postarrow

  " Padding between end of tagline and >
  let padding = 0

  if postarrow == 1
    let padding =  &columns - total_len - 1
    if padding < 0
      let padding = 0
    endif
  endif

  let s = ""

  for i in range(len(prestrs))
    let s .= '%' . (i+1) . 'T%#TabLine#' . prestrs[i]
  endfor

  let s .= '%' . (len(prestrs)+1) . 'T%#TabLineSel#' . activestr

  for i in range(len(poststrs))
    let s .= '%' . (i+len(prestrs)+2) . 'T%#TabLine#' . poststrs[i]
  endfor

  if postarrow
    let s .= "%#TabLine#" . repeat(' ', padding) . ">"
  else
    let s .= '%#TabLineFill#'
  endif

  return s
endfunction
set tabline=%!VIMRC_Tabline()

command -nargs=? Tabname if "<args>" != "" | let t:tab_name="<args>" | else | unlet t:tab_name | endif | redraw!

" }}}

if filereadable(expand("~") . "/.vimrc.local.vim")
  source ~/.vimrc.local.vim
endif

" vim: fdm=marker foldlevel=0
