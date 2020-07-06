setlocal foldmethod=syntax

if !exists("g:arduino_board") | let g:arduino_board="" | endif
if !exists("g:arduino_port") | let g:arduino_port="" | endif
if !exists("g:arduino_ip") | let g:arduino_ip="" | endif

function! s:make(upload)
  if ! exists("g:arduino_board") || empty(g:arduino_board)
    echoe "Must set g:arduino_board first"
    return
  endif
  let l:args = ""
  let l:tmp_makeprg = "bash -c 'arduino-cli \"$@\" 2>&1 | sed \"s%/tmp/arduino-sketch-[^/]*/sketch%.%\"'"
  if a:upload == 1
    if !exists("g:arduino_port") || !filewritable(g:arduino_port)
      echoe "Must set g:arduino_port first"
      echo "Options are:"
      echo glob("/dev/tty{ACM,USB}*")
      return
    endif
    let l:args = "-u -p " . g:arduino_port
  elseif a:upload == 2
    if !exists("g:arduino_ip") || empty(g:arduino_ip)
      echoe "Must set g:arduino_ip first"
      echo "Options are:"
      !avahi-browse -ptr '_arduino._tcp' | grep "^=" | awk -F';' '{printf "\%s (\%s)\n",$8,$4}'
      return
    endif
    let l:tmp_makeprg="bash -c 'set -o pipefail; arduino-cli \"$@\" 2>&1 \\| sed \"s!/tmp/arduino-sketch-[^/]*/sketch!.!\" && python /home/stephen/.arduino15/packages/esp8266/hardware/esp8266/2.5.2/tools/espota.py -i " . g:arduino_ip . " -f *.bin' bash "
  endif
  let l:makeprg = &makeprg
  let &makeprg=l:tmp_makeprg
  exe ":make compile --warnings all " . l:args . " -b " . g:arduino_board | redraw
  copen
  set makeprg=l:makeprg
endfunction

nnoremap <F9> :wa<BAR>call <SID>make(0)<CR>
nnoremap <F12> :wa<BAR>call <SID>make(1)<CR>
nnoremap <F24> :wa<BAR>call <SID>make(2)<CR>
