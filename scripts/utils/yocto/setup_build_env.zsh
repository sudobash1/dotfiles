#!/bin/zsh

if [[ -n $1 ]]; then
  if ! cd $builds/$1; then
    echo "No such build: $1"
    return 1
  fi
  if ! cd ./*(/om[1]); then
    echo "Not built: $1"
    return 1
  fi
fi

local compile_script=$(
  while [[ $(pwd) != "/" ]]; do
    if [[ -f ./temp/run.do_compile ]]; then
      echo $(pwd)/temp/run.do_compile
    fi
    cd .. || exit
  done
)
if [[ -z $compile_script ]]; then
  echo "Never built or invalid directory"
  return 1
fi

python3=$(command -v python3)
old_path="$PATH"
source <( grep --color=never -E "^(export|cd '\/)" ${compile_script} )
export PATH="$PATH:$old_path"
if [[ -n $python3 ]]; then
    export PATH="$(
        $python3 -c '
import os
from collections import OrderedDict
print (":".join(OrderedDict.fromkeys(os.environ.get("PATH","").split(":"))))
'
    )"
    export VIM_YOCTO_CC="$(
        $python3 -c 'import os, shlex
print(shlex.quote(shlex.split(os.environ.get("CXX"))[0]))'
)"

    export VIM_YOCTO_CFLAGS="$(
        $python3 -c '
import os, shlex
arg_vars = ("CXX", "CFLAGS", "CXXFLAGS")
arg_string = " ".join(os.environ.get(x, "") for x in arg_vars)
args = shlex.split(arg_string)
del args[0]
print(" ".join(shlex.quote(a) for a in args))
'
    )"
#    export VIM_YOCTO_CFLAGS="$(
#        $python3 -c '
#import os, shlex
#arg_vars = ("CPP", "CFLAGS", "CPPFLAGS")
#arg_string = " ".join(os.environ.get(x, "") for x in arg_vars)
#args = shlex.split(arg_string)
#del args[0]
#print(
#    " ".join(shlex.quote(a) for a in args if (a[0] != "-" or a[1] not in "fWm"))
#)
#'
#    )"
#    export VIM_YOCTO_CFLAGS="$(
#        $python3 -c '
#import os, shlex
#macros_string="""
#'"$("$(awk '{print $1}' <<< "$CPP")" -E -dM - < /dev/null)"'
#"""
#macros=macros_string.split("\n")
#macros_needed=("__WORDSIZE")
#arg_vars = ("CPP", "CFLAGS", "CPPFLAGS")
#arg_string = " ".join(os.environ.get(x, "") for x in arg_vars)
#args = shlex.split(arg_string)
#del args[0]
#print(
#    " ".join(shlex.quote(a) for a in args if (a[0] != "-" or a[1] not in "fWm"))
#)
#print(
#    " ".join(shlex.quote("-D" + a[1] + "=" + " ".join(a[2:])) for a in (list(m.split()) for m in macros if m) if a[1] in macros_needed)
#)
#'
#    )"
fi
