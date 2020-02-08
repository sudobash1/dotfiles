if (exists("$CC") && (match(getcwd(), "actdl_application") >= 0))
  let g:ale_c_gcc_executable = split($CC)[0]
  let  g:ale_c_gcc_options = "-Wall"
  au FileType c,cpp let b:ale_linters = ['gcc']
endif

command! JimIndentHere setlocal noet ts=4 sw=4 sts=0 cino=1,L2 cin list
command! JimIndentEverywhere set noet ts=4 sw=4 sts=0 cino=1,L2 cin list

au vimrc BufEnter /*/actdl_application/*.[ch] JimIndentHere
