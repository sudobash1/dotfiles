"General Notes About Vim: {{{
"
"to convert the current char to ascii use ga
"
" to paste in insert mode use <Ctrl-R><register> (eg ^R")
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
"  To read an error list loaded in a buffer, use :cb
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
  let py3_path = exepath($NVIM_PYTHON3)
  if ! empty(py3_path)
    let g:python3_host_prog = py3_path
  endif
  let py_path = exepath($NVIM_PYTHON)
  if ! empty(py_path)
    let g:python_host_prog = py_path
  endif
endif
if has('python3')
  py3 import sys
  let s:has_py36 = py3eval("sys.version_info[1] > 6 or " .
                         \ "(sys.version_info[1] == 6 and " .
                         \ " sys.version_info[2] > 1)")
else
  let s:has_py36 = 0
endif

augroup vimrc
" If this vimrc is being resourced, clear the autocommands so they can be
" defined again without duplicates.
au!
augroup END

" Modified from example code from :help <SID>
fun! s:SID()
  return matchstr(expand('<sfile>'), '\zs<SNR>\d\+_\zeSID$')
endfun
" }}}

"============================= VIM PLUG CONFIG ============================= {{{
call plug#begin('~/.vim/bundle')

" have plug install itself
Plug 'junegunn/vim-plug'

Plug 'tpope/vim-repeat' " Helper plugin for vim-surround

if has('nvim')
  Plug 'sudobash1/vim-async-grep' " Async Grep with nvim
endif

Plug 'tpope/vim-surround' " Extra surround keymaps

if (v:version > 704 || v:version == 704 && has("patch1689"))
Plug 'andymass/vim-matchup' " Improve matchparan {{{
  if (v:version > 704 || v:version == 704 && has("patch2180"))
    let g:matchup_matchparen_deferred = 1
  endif
  " let g:matchup_matchparen_offscreen = { 'method': 'popup' }
  let g:matchup_matchparen_offscreen = {}
" }}}
endif

Plug 'tpope/vim-fugitive' " Intigrate vim with git {{{
command! -nargs=* Gshow Git show <args>
"}}}

Plug 'ntpeters/vim-better-whitespace' "Show trailing whitespace

Plug 'ConradIrwin/vim-bracketed-paste' " Automatically enter and leave paste mode

" Plug 'Yggdroot/LeaderF' " Fuzzy Finder {{{
if (v:version >= 703)
  if (v:version > 704 || v:version == 704 && has("patch330"))
    Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
  else
    " Must fall back to v1.01
    Plug 'Yggdroot/LeaderF', { 'tag': 'v1.01', 'do': './install.sh' }
  endif
  if has("nvim-0.4.2") ||
        \ (v:version > 801 || v:version == 801 && has("patch1615"))
    let g:Lf_WindowPosition = 'popup'
  else
    let g:Lf_WindowPosition = 'bottom'
  endif

  let g:Lf_WildIgnore = {
        \ 'dir': ['.svn','.git','.hg','__pycache__'],
        \ 'file': split(&wildignore, '\s*,\s*')
        \}

  let g:Lf_PreviewCode = 1
  let g:Lf_PreviewInPopup = 1
  let g:Lf_UseVersionControlTool = 0
  let g:Lf_PopupWidth = 0.8
  let g:Lf_IgnoreCurrentBufferName = 1
  let g:Lf_DiscardEmptyBuffer = 1
  let g:Lf_JumpToExistingWindow = 0

  nnoremap <silent> <bar> :<c-u>LeaderfBufTag<CR>
  nnoremap <silent> <leader>t :<c-u>LeaderfTag<CR>
  nnoremap <silent> <leader>: :<c-u>LeaderfCommand<CR>
  nnoremap <silent> <leader><s-h> :<c-u>LeaderfHelp<CR>
else
  " No LeaderF for you!
endif
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
  nnoremap <silent> 2<F2> :TagbarOpen f<CR>
  if has('nvim')
    nnoremap <silent> <F14> :TagbarOpen f<CR>
  endif

  let g:tagbar_map_togglefold = "<Space>"
  let g:tagbar_map_showproto = "s"
  let g:tagbar_map_togglesort = "t"

  "let g:tagbar_autoclose = 1
  let g:tagbar_previewwin_pos = "" "Use default loc
  let g:tagbar_sort = 0
  let g:tagbar_autofocus = 0
  let g:tagbar_show_visibility = 1
""}}}

if has('nvim')
  Plug 'sudobash1/vim-gutentags' " Automatically re-generate tag files {{{
    if has('cscope')
      let g:gutentags_modules = ['ctags', 'cscope']
    endif

    " I don't want tags getting automatically generated on me
    let g:gutentags_project_root = ['tags', 'cscope.out']
    let g:gutentags_add_default_project_roots = 0
    let g:gutentags_generate_on_missing = 0
    let g:gutentags_generate_on_new = 0

    let g:gutentags_cscope_build_inverted_index = 1

    " I'm currently only using gutentags for c(++) projects
    let g:gutentags_file_list_command =
          \ 'find . -type f -iname "*.[ch]" -or ' .
          \                '-iname "*.[ch]++" -or ' .
          \                '-iname "*.[ch]xx"'
  "}}}
endif

Plug 'captbaritone/better-indent-support-for-php-with-html' " Indent PHP + HTML files

Plug 'derekwyatt/vim-fswitch' " Toggle between header and source files {{{
    nnoremap <silent> <leader>h :FSHere<cr>
"}}}

Plug 'mattn/emmet-vim' " html editing tools {{{
let g:user_emmet_leader_key='<C-e>'
let g:user_emmet_settings = { 'html' : { 'quote_char' : "'" } }

let g:user_emmet_install_global = 0
au vimrc FileType html,css,php,xml EmmetInstall
"}}}

Plug 'kergoth/vim-bitbake' " Bitbake syntax and file support for vim

if has('nvim')
  Plug 'prabirshrestha/async.vim'
  Plug 'prabirshrestha/vim-lsp'
  inoremap <expr> <C-l> pumvisible() ? "\<lt>c-y>" : "\<lt>c-x>\<lt>c-o>"

  source ~/.vim/vim-lsp-setup.vim
endif

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

if !has('nvim')
  Plug 'sudobash1/vimwits' " Settings for a project {{{
  let g:vimwits_enable = g:vimrc_autoinit
  au vimrc Filetype vim,make,sh let b:vimwits_valid_hi_groups = ["", "Identifier"]
"}}}
endif

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

" Make o and O insert another bullet. Fix gq on single bullets
au vimrc filetype markdown set fo+=o fo-=q
"}}}

Plug 'Vimjas/vim-python-pep8-indent' " Force vim to follow pep8

Plug 'guns/xterm-color-table.vim', {'on': 'XtermColorTable'}

"Unused: {{{

"Plug 'davidhalter/jedi-vim' " Context completion for Python {{{
"let g:jedi#popup_select_first = 0
"let g:jedi#popup_on_dot = 0 "disables the autocomplete to popup whenever you press .
"let g:jedi#auto_vim_configuration = 0 " Don't set completeopt
"
"" s:jedigoto {{{
"func! s:jedigoto()
"  echo
"  redir => l:goto_output
"  silent call jedi#goto_assignments()
"  redir END
"  if l:goto_output != ""
"    try
"      tag expand("<cword>")
"    catch /E257/
"      echohl WarningMsg
"      echo "Tag not found"
"      echohl None
"    endtry
"  endif
"endfunc
"" }}}
"au vimrc FileType python nnoremap <buffer> <silent> <C-]> :call <SID>jedigoto()<CR>
"au vimrc FileType python nnoremap <buffer> <silent> K :call jedi#show_documentation()<CR>
"" }}}

"Plug 'craigemery/vim-autotag' " Automatically re-generate tag files

"if has('cscope')
"  Plug 'sudobash1/cscope_dynamic' "{{{
"  let g:cscopedb_big_file = "cscope.out"
"  let g:cscopedb_small_file = "cache_cscope.out"
"  let g:cscopedb_auto_init = g:vimrc_autoinit
"  let g:cscopedb_auto_files = 1
"
"  function! s:autodir_cscope()
"    let l:dir = getcwd()
"    while l:dir != expand("~") && l:dir != "/"
"      if filereadable(expand(l:dir . "/" . g:cscopedb_big_file))
"        let g:cscopedb_dir = l:dir
"      endif
"      let l:dir = simplify(expand(l:dir . "/.."))
"    endwhile
"  endfunc
"
"  if g:cscopedb_auto_init
"    call s:autodir_cscope()
"  endif
"
"  func! InitCScope()
"    call s:autodir_cscope()
"    execute "normal \<Plug>CscopeDBInit"
"  endfunc
"  "}}}
"endif

"" Async linting [nvim only] (dense-analysis/ale) {{{
"if has('nvim')
"  Plug 'dense-analysis/ale'
"
"  " Use location list instead of quickfix list
"  let g:ale_set_loclist = 1
"  let g:ale_set_quickfix = 0
"
"  let g:ale_c_parse_compile_commands = 1
"
"  " Python {{{
"  if has("python3")
"    py3 import sys
"    let g:ale_python_mypy_options = ' --python-version ' .
"                                     \ py3eval("'3.'+str(sys.version_info[1])")
"  endif
"  " }}}
"endif
"" }}}

"if has('nvim') && s:has_py36
"  " Async completion [nvim only] (Shougo/deoplete.nvim) {{{
"    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"  let g:deoplete#enable_at_startup = 1
"
"  " Make like SuperTab
"  " https://github.com/Shougo/deoplete.nvim/issues/816#issuecomment-409119635
"  function! s:check_back_space() abort
"    let col = col('.') - 1
"    return !col || getline('.')[col - 1]  =~ '\s'
"  endfunction
"  inoremap <silent><expr> <TAB>
"        \ pumvisible() ? "\<C-n>" :
"        \ <SID>check_back_space() ? "\<TAB>" :
"        \ deoplete#manual_complete()
"
"  " Find list of deoplete plugins at https://github.com/Shougo/deoplete.nvim/wiki/Completion-Sources
"  Plug 'Shougo/neco-vim' " deoplete for vimL {{{
"  "}}}
"  "Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' } " Machine learning autocomplete {{{
"  "}}}
"  Plug 'deoplete-plugins/deoplete-jedi' " deoplete for python {{{
"  "}}}
"  Plug 'Shougo/deoplete-clangx' " deoplete for C/C++ {{{
"  "}}}
"
"  " Experimentally using jedi-vim for parameter display only {{{
"    let g:jedi#auto_initialization = 0 " Don't initialize!
"    let g:jedi#completions_enabled = 0 " We are using deoplete-jedi for completions
"    let g:jedi#auto_vim_configuration = 0 " Don't set completeopt
"    let g:jedi#popup_select_first = 0 " Don't auto select first entry
"    let g:jedi#popup_on_dot = 0 "disables the autocomplete to popup whenever you press .
"  " }}}
"  " }}}
"else
"  Plug 'ervandew/supertab' " Tab completion anywhere {{{
"  let g:SuperTabDefaultCompletionType = "context" " Detect if in a pathname, etc...
"  let g:SuperTabContextDefaultCompletionType = "<c-x><c-p>" " If above detect fails fallback to cxcp
"  "let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
"  "let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
"
"  let g:SuperTabClosePreviewOnPopupClose = 1
"  "Should be the same as
"  au vimrc CompleteDone * pclose
"
"  " Jedi vim should be allowed to autocomplete in cases like "from os import "
"  " au vimrc FileType python let b:SuperTabNoCompleteAfter = ['^']
"  " Allow Jedi vim to take precidence
"  "au vimrc FileType python let b:SuperTabDefaultCompletionType = "<C-X><C-O>"
"  " Allow Jedi vim to be the fallback if context fails
"  " au vimrc FileType python call SuperTabSetDefaultCompletionType("<C-X><C-O>")
"
"  " }}}
"endif


"Plug 'junkblocker/patchreview-vim' "{{{ Open up patches or git diffs in separate tabs
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
  endif
endif

if &term =~ '^screen' || &term =~ '^tmux'
    " tmux will send xterm-style keys when its xterm-keys option is on
    execute "set <xUp>=\e[1;*A"
    execute "set <xDown>=\e[1;*B"
    execute "set <xRight>=\e[1;*C"
    execute "set <xLeft>=\e[1;*D"

    if ! has("nvim")
        " tmux knows the extended mouse mode
        if has("mouse_sgr")
          set ttymouse=sgr " For columns beyond 223
        else
          set ttymouse=xterm2
        end
    endif
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
set wildignore=*.bak,*~,*.o,*.info,*.sw?,*.class,*.d,*.pyc,tags

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
set concealcursor=nv

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
if exists("+nomodelineexpr")
  set modeline "You can set vim options in comments
  set nomodelineexpr "But don't execute anything!
endif
set tabpagemax=25 "set the maximum number of pages
set foldmethod=indent "set the method of determining where to fold
set foldlevel=99 "Don't fold by default
set formatoptions+=j "Remove extra comment header on join
set showcmd " Show the multi-key mapping being entered
"set textauto "recognize ^M files
syn on "turn on syntax highlighting

set virtualedit=block " Allow cursor to go where there is no text selected in block select mode

set listchars=eol:$,tab:>-
if (v:version > 704 || v:version == 704 && has("patch710"))
  set listchars+=space:.
endif

"use custom colors.
colorscheme custom

set sessionoptions=blank,buffers,curdir,folds,help,localoptions,options,slash
set sessionoptions+=tabpages,unix,winsize

"indenting defaults
set shiftwidth=4
set softtabstop=-1 " use shiftwidth
"set tabstop=4
set expandtab
set autoindent
set smartindent

"Split settings

"Where new splits will happen.
set splitbelow
set splitright

"Change c indentation rules to match my style:
set cinoptions+=(4m1 "This makes only one indentation happen after (

set cinoptions+=g0 "disable for access modifiers

" Don't show the preview window when completing
set completeopt=menu,menuone,noinsert

" Enable spellcheck for commit messages
au vimrc Filetype svn,*commit* setlocal spell

if has('nvim')
  " Shared clipboard support through ssh, docker, or anything
  " XXX need to make yank aware of multiple clipboards
  let g:clipboard = {
        \   'name': 'osc52-yank',
        \   'copy': {
        \      '+': {lines, regtype -> chansend(v:stderr, system('echo ' . shellescape(join(lines, "\n")) . '|yank'))},
        \      '*': {lines, regtype -> chansend(v:stderr, system('echo ' . shellescape(join(lines, "\n")) . '|yank'))},
        \    },
        \   'paste': {
        \      '+': 'xclip -o -selection clipboard',
        \      '*': 'xclip -o',
        \    },
        \   'cache_enabled': 1,
        \ }

endif

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

  if exists(":Grep")
    call async_grep#grep(l:search, l:args)
  else
    execute "silent! grep! " . l:args . l:search
    botright cwindow
    redraw!
  endif
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

function! s:new_tab_same_buffer() abort
    let l:view = winsaveview()
    tabe %
    call winrestview(l:view)
endfunction
command! TN call <SID>new_tab_same_buffer()
command! UseTabsHere setlocal noet sts=0 sw=0
command! UseTabsEverywhere set noet sts=0 sw=0

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

nnoremap <leader>x :echo printf("0x%x", expand('<cword>'))<CR>

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

"============================== MINI SCRIPTS ============================= {{{

"Error window / Loc window dynamic mappings {{{
if exists("*getwininfo")
  function! s:setup_qfkeymap()
    let l:w = getwininfo(win_getid())[0]
    if l:w.loclist
      unmap <F4>
      unmap <F10>
      unmap <F11>
      nnoremap <silent> <F10> :silent lprevious<CR>
      nnoremap <silent> <F11> :silent lnext<CR>
      nnoremap <silent> <F4> :silent call ToggleLocationList()<CR>
    elseif l:w.quickfix
      unmap <F4>
      unmap <F10>
      unmap <F11>
      nnoremap <silent> <F10> :silent cprevious<CR>
      nnoremap <silent> <F11> :silent cnext<CR>
      nnoremap <silent> <F4> :silent call ToggleQuickfixList()<CR>
    endif
  endfunc
  autocmd BufEnter * call <SID>setup_qfkeymap()
  autocmd BufReadPost * call <SID>setup_qfkeymap()
endif
" }}}

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

" Find and load (or create) a Session.vim file, rewrite it before exit {{{
function! VIMRC_confirm_quit()
  let l:c = confirm("Do you want to save session before quitting?",
                    \ "&Yes\n&No", 0)
  if l:c == 1
    call s:make_session()
  endif
endfunction
function! s:make_session(...)
  let l:path = get(a:000, 0, "")
  if (l:path == "")
    if (v:this_session == "")
      let l:path = "Session.vim"
    else
      let l:path = v:this_session
    endif
  endif
  let l:cmds = [
      \ "augroup VIMRC_session",
      \ "au!",
      \ "au VimLeavePre * call VIMRC_confirm_quit()",
      \ "augroup END",
      \]
  let l:globals = copy(get(g:, "session_globals", []))
  let l:global_pats = get(g:, "session_global_pats", [])
  call add(l:cmds, "let g:session_globals = " . string(l:globals))
  call add(l:cmds, "let g:session_global_pats = " . string(l:global_pats))
  for l:v in l:globals
    let l:v = "g:" . l:v
    if exists(l:v)
      call add(l:cmds, "let " . l:v . " = " . string(eval(l:v)))
    endif
  endfor
  for l:pat in l:global_pats
    " Not sure why there would be quote chars, but anyway...
    let l:pat = escape(l:pat, '"')
    call extend(l:globals, filter(keys(g:), 'v:val !~# "' . l:pat . '"'))
  endfor
  for l:t in range(tabpagenr('$'))
    let l:t = l:t + 1
    for l:var in g:session_tab_vars
      let l:val = gettabvar(l:t, l:var, "VIMRC_DNE_VIMRC")
      if l:val !=# "VIMRC_DNE_VIMRC"
        let l:val = string(l:val)
        call add(l:cmds, "call settabvar(".l:t.",'".l:var."',".l:val.")")
      endif
    endfor
  endfor
  for l:b in range(bufnr('$'))
    let l:b = l:b + 1
    if !bufexists(l:b) | continue | endif
    for l:var in g:session_buf_vars
      let l:val = getbufvar(l:b, l:var, "VIMRC_DNE_VIMRC")
      if l:val !=# "VIMRC_DNE_VIMRC"
        let l:val = string(l:val)
        call add(l:cmds, "call setbufvar(".l:b.",'".l:var."',".l:val.")")
      endif
    endfor
  endfor

  exec "mksession!" l:path
  let l:ses_lines = readfile(l:path)
  let l:end = index(l:ses_lines, "doautoall SessionLoadPost")
  if l:end <= 0 || l:end >= len(l:ses_lines)
    " Odd... Fallback
    let l:lines = extend(l:ses_lines, l:cmds)
  else
    exec "let l:lines_start = copy(l:ses_lines[:".(l:end-1)."])"
    exec "let l:lines_end = copy(l:ses_lines[".l:end.":])"
    let l:lines = extend(extend(l:lines_start, l:cmds), l:lines_end)
  endif
  call writefile(l:lines, l:path)
endfunction
command! -nargs=? Mksession call <SID>make_session("<args>")

function! s:start_session()
  set sessionoptions=blank,buffers,folds,help,localoptions,options,sesdir
  set sessionoptions+=slash,tabpages,unix,winsize,

  let l:dir = getcwd()
  let l:session_dir = ""
  while l:dir != expand("~") && l:dir != "/"
    let l:session_path = l:dir . "/Session.vim"
    if filereadable(expand(l:dir . "/Session.vim"))
      let l:session_dir = l:dir
      break
    endif
    let l:dir = simplify(expand(l:dir . "/.."))
  endwhile
  if !empty(l:session_dir)
    exec "source" l:session_path
  else
    let l:session_path = getcwd() . "/Session.vim"
    echo "No session found, creating session in " .getcwd()
    call s:make_session(l:session_path)
  endif

  augroup VIMRC_session
    au!
    au VimLeavePre * call VIMRC_confirm_quit(l:session_path)
  augroup END
endfunction

command! StartSession call s:start_session()
let g:session_globals = [
    \ "make_dir", "make_file", "make_opts", "make_pos", "make_autojump",
    \ "make_autofocus",
\]
let g:session_global_pats = ["ale_*"]
let g:session_tab_vars = ["tab_name"]
let g:session_buf_vars = ["SuperTabDisabled"]
" }}}

" }}}

"============================== STATUS/TAB LINE ============================= {{{
set statusline=%t\     "tail of the filename

"set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
"set statusline+=%{&ff}] "file format

set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag

"set statusline+=%y      "filetype

set statusline+=%{tagbar#currenttag('\ \ <%s>\ ','\ ')}
set statusline+=%{FugitiveStatusline()}

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
exec 'set tabline=%!' . s:SID() . 'tabline()'

command! -nargs=? Tabname if "<args>" != "" |
                          \   let t:tab_name="<args>" |
                          \ else |
                          \   unlet t:tab_name |
                          \ endif |
                          \ redraw!

" }}}

if filereadable(expand("~") . "/.vimrc.local.vim")
  source ~/.vimrc.local.vim
endif

" vim: fdm=marker foldlevel=0
