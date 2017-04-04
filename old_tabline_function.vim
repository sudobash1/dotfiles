
"modified from https://github.com/mkitt/tabline.vim/blob/master/plugin/tabline.vim
function! VIMRC_Tabline()
  let prearrow = 0  " Use a < at start
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
    let bufmodified = getbufvar(bufnr, "&mod")
    let active = tab == tabpagenr()

    let s = ' ' . tab .':'
    let s .= (bufname != '' ? '['. fnamemodify(bufname, ':t') . '] ' : '[No Name] ')

    if bufmodified
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

  " Trim the string down to fit the screen
"  while prearrow + prelen + activelen + postlen + postarrow > &columns
"    if prelen > postlen
"      let trimed = remove(prestrs, 0)
"      let prelen -= strlen(trimed)
"      let prearrow = 1
"    elseif postlen > 0
"      let trimed = remove(poststrs, -1)
"      let postlen -= strlen(trimed)
"      let postarrow = 1
"    else
"      "We can't even display the entire active tab :(
"      let prearrow = 0
"      let postarrow = 1
"      break
"    endif
"  endwhile

  while prearrow + prelen + activelen + postlen + postarrow > &columns
    if postlen > 0
      let trimed = remove(poststrs, -1)
      let postlen -= strlen(trimed)
      let postarrow = 1
    else
      "We can't even display the entire active tab :(
      let prearrow = 0
      let postarrow = 1
      break
    endif
  endwhile



  let total_len = prearrow + prelen + activelen + postlen + postarrow

  " Padding between end of tagline and >
  let padding = 0

  if postarrow == 1
    let padding =  &columns - total_len - 1
    if padding < 0
      let padding = 0
    endif
  endif

  let s=(prearrow ? "<" : "")

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
