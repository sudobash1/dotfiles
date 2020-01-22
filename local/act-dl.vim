command! JimIndentHere setlocal noet ts=4 sw=4 sts=0 cino=1,L2 cin list
command! JimIndentEverywhere set noet ts=4 sw=4 sts=0 cino=1,L2 cin list

au vimrc BufEnter /*/actdl_application/*.[ch] JimIndentHere
