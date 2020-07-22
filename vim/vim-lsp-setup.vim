function! s:init_mapping() abort
  nnoremap <buffer> <C-]> <CMD>LspDefinition<CR>
  nnoremap <buffer> <leader><S-i> <CMD>LspPeekDefinition<CR>
  nnoremap <buffer> <leader>i <CMD>LspHover<CR>
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

if executable('ccls')
  " For a cross compiler, you will need to tell ccls where to find the system
  " header files. Make a .ccls file in the root of the project with these
  " lines:
  "
  "   %compile_commands.json
  "   --gcc-toolchain=/path/to/gcc/install/root
  "
  " You may also need a -target (replaces gcc's -march):
  "   -target armv7a-linux-gnueabi
  "
  " If there are header file issues, find all gcc's header files with a
  " command like this:
  "   arm-none-eabi-g++ -E -v -xc++ /dev/null
  "   # Or use gcc with -xc for c include paths
  "
  " and add them one by one to the .ccls file like this:
  "   -isystem
  "   /path/to/include/directory
  "
  " If you don't have a .ccls you need a compile_commands.json file in the
  " root directory (you can have both if needed).

  function! s:ccls_init() abort
    let l:root_path = s:get_root_path(['compile_commands.json', '.ccls', '.ccls.init.json'])
    call lsp#register_server({
         \ 'name': 'ccls',
         \ 'cmd': {server_info->['ccls']},
         \ 'root_uri': {server_info->lsp#utils#path_to_uri(l:root_path)},
         \ 'initialization_options': s:get_init_json(l:root_path, '.ccls.init.json', {}),
         \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
         \ })
  endfunction
  augroup lsp_ccls
    au!
    au User lsp_setup call s:ccls_init()
    au FileType c,cpp,objc call s:init_mapping()
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
