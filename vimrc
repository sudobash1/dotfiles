
"General Notes About Vim: {{{
"
"to convert the current char to ascii use ga
"
" to convert from ^M files to unix files, run :set ff=unix
" to test if something is "set" in vimscript use the ampersand & prefix
" to use a regsiter in vimscript use the at @ prefix
" use <c-u> <c-d> and scroll option for fast navigation
" use <c-T> to navigate back from <c-]>
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
" "= will prompt you for an expression (1+1 or system('ls') etc...) and will
" allow you to <p>ut the result
" \= will allow you to use the result of a vim command as the replacement text
" in a substitute command (eg  :%s/\d\+/\=printf("0x%04x", submatch(0)) )
"
" <c-r><register> will paste the register in insert mode or command mode
" (this is usefull for s/<c-r>//to replace/ because <c-r>/ will show the last
"  searched string)
"  Use " for the unnamed register
"
" }}}

let g:vimrc_autoinit = 0
if index(['1', 'yes', 'on', 'true', 'y', 't', 'enable'], tolower($VIM_AUTOINIT)) >= 0
  let g:vimrc_autoinit = 1
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
Plugin 'vundle/Vundle.vim'

Plugin 'ntpeters/vim-better-whitespace' "Show trailing whitespace {{{
"}}}

Plugin 'Superbil/llvm.vim' "Syntax highlighting for llvm IR {{{
"}}}

Plugin 'kien/ctrlp.vim' " Fuzzy file finder {{{
let g:ctrlp_map = ''
nnoremap <F1> :CtrlP .<CR>
let g:ctrlp_by_filename = 1
"}}}

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
  Plugin 'erig0/cscope_dynamic' "{{{
  let g:cscopedb_big_file = "cscope.out"
  let g:cscopedb_small_file = "cache_cscope.out"
  let g:cscopedb_auto_init = g:vimrc_autoinit
  let g:cscopedb_auto_files = 1
  function s:autodir_cscope()
    let orig_cwd = getcwd()
    while getcwd() != expand("~") && getcwd() != "/"
      if filereadable("cscope.out")
        return
      endif
      cd ..
    endwhile
    execute "cd " . orig_cwd
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

Plugin 'sudobash1/vprojman.vim' " Settings for a project {{{
let g:vprojman_autoinit = g:vimrc_autoinit
let g:vprojman_signature = "-sbr-"
let g:vprojman_copen_pos = "botright"

let g:run_target = "run"
nnoremap <F9>  :call vprojman#make()<CR>
nnoremap <F12> :call vprojman#make(g:run_target)<CR>

command CustCMDpatch call vprojman#patch()
"}}}


"Unused: {{{

"Plugin 'dirkwallenstein/vim-autocomplpop' " automatically open popup window {{{
"Plugin 'eparreno/vim-l9' "Required by autocomplpop
"let g:AutoComplPopDontSelectFirst = 1
"let g:acp_ignorecaseOption = 0 "Don't ignore case
"let g:acp_enableAtStartup = 0 "DISABLE
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
set ttimeoutlen=250

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
set tabstop=4
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
  "set cscoperelative
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
  func s:cscopecmd(cmd, word, word2)

    if a:word != ""
      let word = a:word
    else
      let word = a:word2
    endif

    if word == ""
      let error = "ERROR: You must have the cursor on a word"
      if a:cmd != "d"
        let error .= " or provide an argument"
      endif
      echom error
      return
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
      cexpr []
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

  command -nargs=? CustCMDcs call <SID>cscopecmd("s", "<args>", expand("<cword>"))
  command -nargs=? CustCMDcg call <SID>cscopecmd("g", "<args>", expand("<cword>"))
  command CustCMDcd call <SID>cscopecmd("d", "", substitute(tagbar#currenttag('%s',''),"()","",""))
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

"Press space to toggle current fold
nnoremap <space> za

"Press F1 to start selecting a buffer to switch too.
"nnoremap <F1> :buffer

"Doublepress the leader to get a prompt to do one of my custom commands
nnoremap <leader><leader> :CustCMD

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

"The directory the MAKEFILE is in.
let g:make_dir = "."
let g:make_opts = "run"


" commit messages {{{
autocmd Filetype svn,*commit* setlocal spell
" }}}

" Java {{{
autocmd Filetype java set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
"autocmd Filetype java nnoremap <F9> :wa<CR>:execute "make -C ".g:make_dir<CR><CR>:botright copen<CR>:wincmd p<CR>
"autocmd Filetype java nnoremap <F12> :wa<CR>:execute "make -C ".g:make_dir." ".g:make_opts<CR><CR>

"autocmd Filetype java inoremap {<CR> {<CR>}<C-O>O
"autocmd Filetype java inoremap {{ <CR>{<CR>}<C-O>O
"autocmd Filetype java inoremap { {}<Left>
"autocmd Filetype java inoremap {<ESC> <C-O>a
"autocmd Filetype java inoremap {[ {

" }}}

" C++ {{{
autocmd Filetype cpp set errorformat=%f:%l:%c:%m,%f:kk%l:\ %m,In\ file\ included\ from\ %f:%l:,\^I\^Ifrom\ %f:%l%m,\"%f\"\\\,\ line\ %l.%c:%m\,\ %f:%l:%m,%f:%l:%c:%m
autocmd Filetype cpp set errorformat^=%-GIn\ file\ included\ %.%# 
autocmd Filetype cpp set errorformat^=%-Gavrdude%.%#
"autocmd Filetype cpp nnoremap <F9>  :wa<CR>:execute "make -C ".g:make_dir<CR><CR>:botright copen<CR>:wincmd p<CR>
"autocmd Filetype cpp nnoremap <F12> :wa<CR>:execute "make -C ".g:make_dir." ".g:make_opts<CR><CR><CR>
autocmd Filetype cpp set foldmethod=syntax
" }}}

" C {{{
autocmd Filetype c set errorformat=%f:%l:%c:%m,%f:kk%l:\ %m,In\ file\ included\ from\ %f:%l:,\^I\^Ifrom\ %f:%l%m,\"%f\"\\\,\ line\ %l.%c:%m\,\ %f:%l:%m,%f:%l:%c:%m
autocmd Filetype c set errorformat^=%-GIn\ file\ included\ %.%# 
autocmd Filetype c set errorformat^=%-Gavrdude%.%#
"autocmd Filetype c nnoremap <F9>  :wa<CR>:execute "make -C ".g:make_dir<CR><CR>:botright copen<CR>:wincmd p<CR>
"autocmd Filetype c nnoremap <F12> :wa<CR>:execute "make -C ".g:make_dir." ".g:make_opts<CR><CR><CR>
" }}}

" SML {{{
" no autowrap XXX Why can't I put the t and c on one line?
autocmd Filetype sml setlocal formatoptions-=t
autocmd Filetype sml setlocal formatoptions-=c
autocmd filetype sml setlocal shiftwidth=2
autocmd filetype sml setlocal softtabstop=2
" }}}

" Text {{{
autocmd filetype text setlocal linebreak
autocmd filetype text setlocal cc=0
autocmd filetype text setlocal nonu
autocmd filetype text setlocal spell
autocmd filetype help setlocal nospell
autocmd FileType text setlocal textwidth=0
autocmd filetype text setlocal tabstop=4
autocmd filetype text setlocal noexpandtab
autocmd filetype text noremap <buffer> <up> gk
autocmd filetype text noremap <buffer> k gk
autocmd filetype text noremap <buffer> <down> gj
autocmd filetype text noremap <buffer> j gj
autocmd filetype text noremap <buffer> ^ g^
autocmd filetype text noremap <buffer> $ g$
autocmd filetype text nnoremap <buffer> I g^i
autocmd filetype text nnoremap <buffer> A g$a
" }}}

" Assembly {{{

"disable tab completion for asm files
silent autocmd filetype asm let b:SuperTabDisabled = 1

autocmd filetype asm setlocal tabstop=8
autocmd filetype asm setlocal shiftwidth=8
autocmd filetype asm setlocal softtabstop=8
autocmd filetype asm setlocal noexpandtab
" }}}

" Special Indentation Rules {{{

autocmd filetype html setlocal shiftwidth=2
autocmd filetype php setlocal shiftwidth=2
autocmd filetype css setlocal shiftwidth=2
autocmd filetype vim setlocal shiftwidth=2
autocmd filetype sh setlocal shiftwidth=2

autocmd filetype make setlocal tabstop=8
autocmd filetype make setlocal noexpandtab

set softtabstop=-1 " use shiftwidth

" }}}

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

" }}}

"============================== STATUSLINE ============================= {{{
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

" }}}

if filereadable(expand("~") . "/.vimrc.local.vim")
  source ~/.vimrc.local.vim
endif

" vim: fdm=marker foldlevel=0
