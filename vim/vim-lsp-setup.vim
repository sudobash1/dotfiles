function! s:init_mapping() abort
  nnoremap <buffer> <C-]> <CMD>LspDefinition<CR>
  nnoremap <buffer> <leader><S-i> <CMD>LspPeekDefinition<CR>
  nnoremap <buffer> <leader>i <CMD>LspHover<CR>
  "nnoremap <buffer> <silent> <C-W><C-]> :echo 'Split Definition'<bar>ALEGoToDefinition -split<CR>
  "nnoremap <buffer> <silent> <C-W>] :echo 'Split Definition'<bar>ALEGoToDefinition -split<CR>
endfunction

function! s:deep_merge(dict, def) abort
  for l:key in keys(a:dict)
    if type(a:dict[l:key]) ==# v:t_dict &&
          \ has_key(a:def, l:key) &&
          \ type(a:def[l:key]) ==# v:t_dict
      let a:dict[l:key] = s:merge(a:dict[l:key], a:def[l:key])
    endif
  endfor
  return extend(a:dict, a:def, 'keep')
endfunction

function! s:get_root_path(markers) abort
  let l:buffer_path = expand('%:h:p')
  for l:marker in a:markers
    let l:root_path = lsp#utils#find_nearest_parent_file_directory(
          \ l:buffer_path,
          \ l:marker
          \ )
    if l:root_path !=# ''
      return l:root_path
    endif
  endfor
  return l:buffer_path
endfunction

function! s:get_init_json(root_path, name, defaults) abort
  let l:init_json_file = a:root_path . '/' . a:name
  if filereadable(l:init_json_file)
    try
      let l:init = json_decode(readfile(l:init_json_file))
      return s:deep_merge(l:init, a:defaults)
    catch
      " XXX Test and improve error handling
      echoe 'Invalid json in configuration file ' . l:init_json_file
    endtry
  endif
  return a:defaults
endfunction

if executable('clangd')
  au User lsp_setup call lsp#register_server({
        \ 'name' :'clangd',
        \ 'cmd' : {server_info->['clangd', '-background-index']},
        \ 'whitelist' : ['c', 'cpp', 'objc', 'objcpp'],
        \ })

  function! s:clangd_init() abort
    let l:root_path = s:get_root_path(['compile_commands.json', '.clangd.init.json', '.clangd'])
    call lsp#register_server({
         \ 'name' :'clangd',
         \ 'cmd' : {server_info->['clangd', '-background-index', '--enable-config']},
         \ 'root_uri': {server_info->lsp#utils#path_to_uri(l:root_path)},
         \ 'initialization_options': s:get_init_json(l:root_path, '.clang.init.json', {}),
         \ 'whitelist' : ['c', 'cpp', 'objc', 'objcpp'],
         \ })
  endfunction
  augroup lsp_clangd
    au!
    au User lsp_setup call s:clangd_init()
    au FileType c,cpp,objc call s:init_mapping()
  augroup END
endif
"if executable('ccls')
"  " For a cross compiler, you will need to tell ccls where to find the system
"  " header files. Make a .ccls file in the root of the project with these
"  " lines:
"  "
"  "   %compile_commands.json
"  "   --gcc-toolchain=/path/to/gcc/install/root
"  "
"  " You may also need a -target (replaces gcc's -march):
"  "   -target armv7a-linux-gnueabi
"  "
"  " If there are header file issues, find all gcc's header files with a
"  " command like this:
"  "   arm-none-eabi-g++ -E -v -xc++ /dev/null
"  "   # Or use gcc with -xc for c include paths
"  "
"  " and add them one by one to the .ccls file like this:
"  "   -isystem
"  "   /path/to/include/directory
"  "
"  " If you don't have a .ccls you need a compile_commands.json file in the
"  " root directory (you can have both if needed).
"  function! s:ccls_init() abort
"    let l:root_path = s:get_root_path(['compile_commands.json', '.ccls', '.ccls.init.json'])
"    call lsp#register_server({
"         \ 'name': 'ccls',
"         \ 'cmd': {server_info->['ccls']},
"         \ 'root_uri': {server_info->lsp#utils#path_to_uri(l:root_path)},
"         \ 'initialization_options': s:get_init_json(l:root_path, '.ccls.init.json', {}),
"         \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
"         \ })
"  endfunction
"  augroup lsp_ccls
"    au!
"    au User lsp_setup call s:ccls_init()
"    au FileType c,cpp,objc call s:init_mapping()
"  augroup END
"endif
if executable('vim-language-server')
  augroup lsp_vim
    au!
    au User lsp_setup call lsp#register_server({
        \ 'name': 'vim-language-server',
        \ 'cmd': {server_info->['vim-language-server', '--stdio']},
        \ 'whitelist': ['vim'],
        \ 'initialization_options': {
        \   'vimruntime': $VIMRUNTIME,
        \   'runtimepath': &rtp,
        \ }})
    au FileType vim call s:init_mapping()
  augroup END
endif
if executable('pyls')
    function! s:pyls_init() abort
      let l:root_path = s:get_root_path(['.pyls.init.json'])
      let l:def_init = {
            \ 'pyls': {
            \   'plugins': {
            \     'pycodestyle': {
            \       'enabled': v:false
            \      },
            \     'pyls_mypy': {
            \       'enabled': v:true
            \      }
            \    }
            \  }
            \ }
      call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'root_uri': {server_info->lsp#utils#path_to_uri(l:root_path)},
        \ 'workspace_config': s:get_init_json(l:root_path, '.pyls.init.json', l:def_init),
        \ 'whitelist': ['python'],
        \ })
    endfunction
    augroup lsp_pyls
      au!
      au User lsp_setup call s:pyls_init()
      au FileType python call s:init_mapping()
    augroup END
endif

if executable('css-languageserver')
  function! s:css_init() abort
    let l:root_path = s:get_root_path(['.css.init.json'])
    call lsp#register_server({
      \ 'name': 'css-languageserver',
      \ 'cmd': {server_info->[&shell, &shellcmdflag, 'css-languageserver --stdio']},
      \ 'root_uri': {server_info->lsp#utils#path_to_uri(l:root_path)},
      \ 'workspace_config': s:get_init_json(l:root_path, '.css.init.json', {}),
      \ 'whitelist': ['css', 'less', 'sass'],
      \ })
  endfunction
  augroup lsp_css
    au!
    au User lsp_setup call s:css_init()
    au FileType css,less,sass call s:init_mapping()
  augroup END
endif
if executable('typescript-language-server')
  function! s:js_init() abort
    let l:root_path = s:get_root_path(['.js.init.json'])
    call lsp#register_server({
      \ 'name': 'typescript-language-server',
      \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
      \ 'root_uri': {server_info->lsp#utils#path_to_uri(l:root_path)},
      \ 'workspace_config': s:get_init_json(l:root_path, '.js.init.json', {}),
      \ 'whitelist': ['javascript', 'javascript.jsx', 'javascriptreact'],
      \ })
  endfunction
  augroup lsp_js
    au!
    au User lsp_setup call s:js_init()
    au FileType javascript,typescript call s:init_mapping()
  augroup END
endif
if executable('html-languageserver')
  function! s:html_init() abort
    let l:root_path = s:get_root_path(['.html.init.json'])
    call lsp#register_server({
      \ 'name': 'html-languageserver',
      \ 'cmd': {server_info->[&shell, &shellcmdflag, 'html-languageserver --stdio']},
      \ 'root_uri': {server_info->lsp#utils#path_to_uri(l:root_path)},
      \ 'workspace_config': s:get_init_json(l:root_path, '.html.init.json', {}),
      \ 'whitelist': ['html'],
      \ })
  endfunction
  augroup lsp_html
    au!
    au User lsp_setup call s:html_init()
    au FileType html call s:init_mapping()
  augroup END
endif
"if executable('texlab')
"  function! s:texlab_init() abort
"    let l:root_path = s:get_root_path(['.texlab.init.json'])
"    call lsp#register_server({
"      \ 'name': 'texlab',
"      \ 'cmd': {server_info->[&shell, &shellcmdflag, 'texlab']},
"      \ 'root_uri': {server_info->lsp#utils#path_to_uri(l:root_path)},
"      \ 'workspace_config': s:get_init_json(l:root_path, '.texlab.init.json', {}),
"      \ 'whitelist': ['tex', 'latex', 'luatex'],
"      \ })
"  endfunction
"  augroup lsp_texlab
"    au!
"    au User lsp_setup call s:texlab_init()
"    au FileType tex call s:init_mapping()
"  augroup END
"endif

if executable('bash-language-server')
  function! s:bash_init() abort
    let l:root_path = s:get_root_path(['.bash.init.json'])
    call lsp#register_server({
          \ 'name': 'bash-language-server',
          \ 'cmd': {server_info->[&shell, &shellcmdflag, 'bash-language-server start']},
          \ 'root_uri': {server_info->lsp#utils#path_to_uri(l:root_path)},
          \ 'workspace_config': s:get_init_json(l:root_path, '.bash.init.json', {}),
          \ 'allowlist': ['sh'],
          \ })
  endfunction
  augroup lsp_bash
    au!
    au User lsp_setup call s:bash_init()
    au FileType sh call s:init_mapping()
  augroup END
endif

if executable('efm-langserver')
  function! s:efm_init() abort
    let l:root_path = s:get_root_path(['.efm.init.json'])
    call lsp#register_server({
          \ 'name': 'efm-languageserver',
          \ 'cmd': {server_info->['efm-langserver']},
          \ 'whitelist': ['sh'],
          \ })
  endfunction
  augroup lsp_efm
    au!
    au User lsp_setup call s:efm_init()
    " au FileType sh call s:init_mapping() --- No Mappings
  augroup END
endif

if executable('gopls')
  function! s:gopls_init() abort
    let l:root_path = s:get_root_path(['.gopls.init.json'])
    call lsp#register_server({
          \ 'name': 'gopls',
          \ 'cmd': {server_info->['gopls']},
          \ 'whitelist': ['go'],
          \ })
  endfunction
  augroup lsp_gopls
    au!
    au User lsp_setup call s:gopls_init()
    au FileType go call s:init_mapping()
  augroup END
endif

let s:JDTLS_PATH = expand('~/.vim/tools/eclipse.jdt.ls/startjdls.sh')
if executable(s:JDTLS_PATH)
  function! s:jdtls_init() abort
    let l:root_path = s:get_root_path(['.jdtls.init.json'])
    call lsp#register_server({
          \ 'name': 'eclipse.jdt.ls',
          \ 'cmd': {server_info->[s:JDTLS_PATH, getcwd()]},
          \ 'whitelist': ['java'],
          \ })
  endfunction
  augroup lsp_jdtls
    au!
    au User lsp_setup call s:jdtls_init()
    au FileType java call s:init_mapping()
  augroup END
endif

if executable('diagnostic-languageserver')
  function! s:dls_init() abort
    let l:root_path = s:get_root_path(['.dls.init.json'])
    call lsp#register_server({
          \ 'name': 'diagnostic-languageserver',
          \ 'cmd': {server_info->['diagnostic-languageserver', '--stdio', '--log-level', '2']},
          \ 'whitelist': ['sh', 'zsh'],
          \ 'initialization_options': {
          \   'linters': {
          \     "shellcheck": {
          \       "command": "shellcheck",
          \       "debounce": 100,
          \       "args": [
          \         "--format",
          \         "json",
          \         "-"
          \       ],
          \       "sourceName": "shellcheck",
          \       "parseJson": {
          \         "line": "line",
          \         "column": "column",
          \         "endLine": "endLine",
          \         "endColumn": "endColumn",
          \         "message": "${message} [${code}]",
          \         "security": "level"
          \       },
          \       "securities": {
          \         "error": "error",
          \         "warning": "warning",
          \         "info": "info",
          \         "style": "hint"
          \       }
          \     }
          \   },
          \   'filetypes': {
          \     'sh': 'shellcheck',
          \     'zsh': 'shellcheck',
          \   },
          \ }
          \ })
  endfunction
  augroup lsp_dls
    au!
    au User lsp_setup call s:dls_init()
    au FileType sh,zsh call s:init_mapping()
  augroup END
endif

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
endfunction

function! s:on_lsp_diagnostics_updated() abort
  if lsp#get_buffer_first_error_line() ==# v:null
    setlocal signcolumn=no
  else
    setlocal signcolumn=yes
  endif
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  autocmd User lsp_setup highlight lspReference term=underline cterm=underline gui=underline
  autocmd User lsp_diagnostics_updated call s:on_lsp_diagnostics_updated()
augroup END

"let g:lsp_fold_enabled = 0
let g:lsp_virtual_text_enabled = 0
"let g:lsp_diagnostics_float_cursor = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_diagnostics_echo_delay = 1
let g:lsp_highlight_references_enabled = 1
